const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  age: { type: Number, default: 18 },
  bio: String,
  photoUrl: String,
  location: String,
  interests: [String],
});

module.exports = mongoose.model("User", userSchema);
