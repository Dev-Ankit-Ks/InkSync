const express = require("express");
const http = require("http");
const cors = require("cors");
const app = express();
const Room = require("./models/Room");
require("dotenv").config();
const port = process.env.PORT || 5000;
const connectDB = require("./config/db");
const getWord = require("./Api/getWord");
app.use(cors());
const server = http.createServer(app);
const io = require("socket.io")(server, {
  cors: {
    origin: "*", 
    methods: ["GET", "POST"],
  },
  transports: ["websocket", "polling"],
});
app.use(express.json());

connectDB();

io.on("connection", (socket) => {
  console.log("Connected...to Socket id : ", socket.id);
  socket.on("create-game", async ({ nickname, name, occupancy, maxRounds }) => {
    try {
      const existingRoom = await Room.findOne({ name });
      if (existingRoom) {
        socket.emit("notCorrectGame", "Room Already Created");
        return;
      }
      let room = new Room();
      const word = getWord();
      room.word = word;
      room.name = name;
      room.occupancy = occupancy;
      room.maxRounds = maxRounds;

      let player = {
        socketID: socket.id,
        nickname,
        isPartyLeader: true,
      };
      room.players.push(player);
      room = await room.save();
      socket.join(name);
      io.to(name).emit("updateRoom", room);
    } catch (error) {
      console.log(err);
    }
  });

  socket.on("join-game", async ({ nickname, name }) => {
    try {
      let room = await Room.findOne({ name });
      if (!room) {
        socket.emit("notCorrectGame", "Please enter valid room name");
        return;
      }
      if (room.isJoin) {
        let player = {
          socketID: socket.id,
          nickname,
        };
        room.players.push(player);
        socket.join(name);
        if (room.players.length === room.occupancy) {
          room.isJoin = false;
        }
        room.turn = room.players[room.turnIndex];
        room = await room.save();
        io.to(name).emit("updateRoom", room);
      } else {
        socket.emit("notCorrectGame", "The game is in Progress wait...");
      }
    } catch (err) {
      console.log("Error", err);
    }
  });

  socket.on("msg", async (data) => {
    try {
      if (data.msg === data.word) {
        let room = await Room.find({ name: data.roomName });
        let userPlayer = room[0].players.filter(
          (player) => player.nickname === data.username
        );
        if (data.timeTaken !== 0) {
          userPlayer[0].points += Math.round((200 / data.timeTaken) * 10);
        }
        room = await room[0].save();
        io.to(data.roomName).emit("msg", {
          username: data.username,
          msg: "Guessed it!",
          guessedUserCtr: data.guessedUserCtr + 1,
        });
        socket.emit("closeInput", "");
      } else {
        io.to(data.roomName).emit("msg", {
          username: data.username,
          msg: data.msg,
          guessedUserCtr: data.guessedUserCtr,
        });
      }
    } catch (error) {
      console.log(error);
    }
  });

  socket.on("change-turn", async (name) => {
    try {
      let room = await Room.findOne({ name });
      let idx = room.turnIndex;
      if (idx + 1 === room.players.length) {
        room.currentRound += 1;
      }
      if (room.currentRound <= room.maxRounds) {
        const word = getWord();
        room.word = word;
        room.turnIndex = (idx + 1) % room.players.length;
        room.turn = room.players[room.turnIndex];
        room = await room.save();
        io.to(name).emit("change-turn", room);
      } else {
        io.to(name).emit("show-leaderboard", room.players);
      }
    } catch (error) {
      console.log(error);
    }
  });

  socket.on("updateScore", async (name) => {
    try {
      const room = await Room.findOne({ name });
      io.to(name).emit("updateScore", room);
    } catch (err) {
      console.log(err);
    }
  });

  socket.on("paint", ({ details, roomName, paint }) => {
    io.to(roomName).emit("points", {
      details: details,
      paint: paint,
    });
  });

  socket.on("color-change", ({ color, roomName }) => {
    io.to(roomName).emit("color-change", color);
  });

  socket.on("stroke-width", ({ value, roomName }) => {
    io.to(roomName).emit("stroke-width", value);
  });

  socket.on("clean-screen", (roomName) => {
    io.to(roomName).emit("clean-screen", "");
  });

  socket.on("disconnect", async () => {
    try {
      let room = await Room.findOne({ "players.socketID": socket.id });

      if (!room) {
        console.log("No room found for disconnected socket:", socket.id);
        return;
      }

      room.players = room.players.filter((p) => p.socketID !== socket.id);
      await room.save();

      if (room.players.length === 1) {
        socket.broadcast.to(room.name).emit("show-leaderboard", room.players);
      } else {
        socket.broadcast.to(room.name).emit("user-disconnected", room);
      }
    } catch (err) {
      console.log("Disconnect error:", err);
    }
  });
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Server is up and running on port and fixed one: ${port}`);
});
