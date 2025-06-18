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
const io = require("socket.io")(server);
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

  socket.on('paint' , ({details , roomName})=>{
    io.to(roomName).emit('points' , {details : details});
  })
});

server.listen(port, "0.0.0.0", () => {
  console.log(`🚀 Server is up and running on port: ${port}`);
});
