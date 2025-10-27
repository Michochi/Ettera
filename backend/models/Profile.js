const mongoose = require("mongoose");

const profileSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, unique: true },
  age: { type: Number, required: true },
  location: String,
  interests: [String],
  photos: [String],
  // Tracking arrays for swipe history
  likedProfiles: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  passedProfiles: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  matches: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Profile", profileSchema);
