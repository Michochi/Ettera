const User = require("../models/User");
const Profile = require("../models/Profile");
const Match = require("../models/Match");
const Message = require("../models/Message");

// Get profiles to browse (excluding already seen profiles)
exports.getProfiles = async (req, res) => {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 20;

    // Get or create current user's profile
    let userProfile = await Profile.findOne({ userId });
    if (!userProfile) {
      userProfile = await Profile.create({ userId, age: 18 });
    }

    // Get IDs of profiles to exclude (already liked, passed, or matched)
    const excludedIds = [
      userId,
      ...userProfile.likedProfiles,
      ...userProfile.passedProfiles,
      ...userProfile.matches,
    ];

    // Find profiles that haven't been seen yet
    const profiles = await Profile.find({
      userId: { $nin: excludedIds },
    })
      .limit(limit)
      .populate("userId", "name email photoUrl bio gender");

    // Transform the data
    const profilesData = profiles.map((profile) => ({
      id: profile.userId._id,
      name: profile.userId.name,
      email: profile.userId.email,
      age: profile.age,
      bio: profile.userId.bio || "",
      photoUrl: profile.userId.photoUrl,
      location: profile.location,
      interests: profile.interests || [],
      gender: profile.userId.gender,
    }));

    res.json({ profiles: profilesData });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Like a profile (swipe right)
exports.likeProfile = async (req, res) => {
  try {
    const userId = req.userId;
    const { profileId } = req.body;

    if (!profileId) {
      return res.status(400).json({ message: "Profile ID is required" });
    }

    // Get or create current user's profile
    let userProfile = await Profile.findOne({ userId });
    if (!userProfile) {
      userProfile = await Profile.create({ userId, age: 18 });
    }

    // Add to liked profiles if not already there
    if (!userProfile.likedProfiles.includes(profileId)) {
      userProfile.likedProfiles.push(profileId);
      await userProfile.save();
    }

    // Check if the other user has liked this user back
    const otherUserProfile = await Profile.findOne({ userId: profileId });
    
    let isMatch = false;
    let matchData = null;

    if (otherUserProfile && otherUserProfile.likedProfiles.includes(userId)) {
      // It's a match!
      isMatch = true;

      // Add to matches for both users
      if (!userProfile.matches.includes(profileId)) {
        userProfile.matches.push(profileId);
        await userProfile.save();
      }

      if (!otherUserProfile.matches.includes(userId)) {
        otherUserProfile.matches.push(userId);
        await otherUserProfile.save();
      }

      // Create match record
      const [smallerId, largerId] = [userId, profileId].sort();
      let match = await Match.findOne({
        user1: smallerId,
        user2: largerId,
      });

      if (!match) {
        match = await Match.create({
          user1: smallerId,
          user2: largerId,
        });
        console.log('Match created:', match); // Debug log
      } else {
        console.log('Match already exists:', match); // Debug log
      }

      // Get matched user details
      const matchedUser = await User.findById(profileId).select("-password");
      matchData = {
        id: match._id,
        userId: userId,
        matchedUserId: profileId,
        matchedUserName: matchedUser.name,
        matchedUserPhoto: matchedUser.photoUrl,
        matchedAt: match.matchedAt,
      };
    }

    res.json({
      message: isMatch ? "It's a match!" : "Profile liked",
      isMatch,
      match: matchData,
    });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Pass a profile (swipe left)
exports.passProfile = async (req, res) => {
  try {
    const userId = req.userId;
    const { profileId } = req.body;

    if (!profileId) {
      return res.status(400).json({ message: "Profile ID is required" });
    }

    // Get or create current user's profile
    let userProfile = await Profile.findOne({ userId });
    if (!userProfile) {
      userProfile = await Profile.create({ userId, age: 18 });
    }

    // Add to passed profiles if not already there
    if (!userProfile.passedProfiles.includes(profileId)) {
      userProfile.passedProfiles.push(profileId);
      await userProfile.save();
    }

    res.json({ message: "Profile passed" });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Get user's matches
exports.getMatches = async (req, res) => {
  try {
    const userId = req.userId;

    const userProfile = await Profile.findOne({ userId }).populate(
      "matches",
      "name email photoUrl bio"
    );

    if (!userProfile) {
      return res.json({ matches: [] });
    }

    const matches = userProfile.matches.map((user) => ({
      id: user._id,
      name: user.name,
      email: user.email,
      photoUrl: user.photoUrl,
      bio: user.bio || "",
    }));

    res.json({ matches });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Unmatch with a user
exports.unmatch = async (req, res) => {
  try {
    const userId = req.userId;
    const { matchId } = req.params;

    // Remove from both users' matches
    await Profile.findOneAndUpdate(
      { userId },
      { $pull: { matches: matchId } }
    );

    await Profile.findOneAndUpdate(
      { userId: matchId },
      { $pull: { matches: userId } }
    );

    // Deactivate match record
    const [smallerId, largerId] = [userId, matchId].sort();
    await Match.findOneAndUpdate(
      { user1: smallerId, user2: largerId },
      { active: false }
    );

    // Delete all messages between the two users
    await Message.deleteMany({
      $or: [
        { senderId: userId, receiverId: matchId },
        { senderId: matchId, receiverId: userId }
      ]
    });

    console.log(`🗑️ Unmatched: ${userId} and ${matchId}, messages deleted`);

    // Emit socket event to notify the other user
    const io = req.app.get('io');
    const activeUsers = req.app.get('activeUsers');
    if (io && activeUsers) {
      const matchSocketId = activeUsers.get(matchId);
      if (matchSocketId) {
        io.to(matchSocketId).emit('user_unmatched', {
          userId: userId,
          message: 'You have been unmatched'
        });
      }
    }

    res.json({ message: "Unmatched successfully" });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};
