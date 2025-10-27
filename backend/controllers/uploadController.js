const User = require("../models/User");

// Upload profile picture (Base64)
exports.uploadProfilePicture = async (req, res) => {
  try {
    const userId = req.userId;
    const { imageData } = req.body; // Base64 image data

    if (!imageData) {
      return res.status(400).json({ message: "No image data provided" });
    }

    // Validate base64 format
    if (!imageData.startsWith('data:image')) {
      return res.status(400).json({ message: "Invalid image format" });
    }

    // Update user with base64 image
    const user = await User.findByIdAndUpdate(
      userId,
      { photoUrl: imageData },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ 
      message: "Profile picture updated successfully", 
      user 
    });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Delete profile picture
exports.deleteProfilePicture = async (req, res) => {
  try {
    const userId = req.userId;

    const user = await User.findByIdAndUpdate(
      userId,
      { photoUrl: null },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ 
      message: "Profile picture deleted successfully", 
      user 
    });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};
