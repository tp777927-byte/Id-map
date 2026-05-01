const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// ✅ แก้ Failed to fetch
app.use(cors());

// ใช้ JSON
app.use(express.json());

// 📦 เก็บคีย์ (ชั่วคราว)
let keysDatabase = [];

// 🔍 เช็ค 24 ชม
function hasRecentKey(userId) {
    const userKeys = keysDatabase.filter(k => k.userId === userId);
    if (userKeys.length === 0) return false;

    const latestKey = userKeys.reduce((a, b) =>
        new Date(a.time) > new Date(b.time) ? a : b
    );

    const diff = (Date.now() - new Date(latestKey.time)) / (1000 * 60 * 60);
    return diff < 24;
}

// 🔑 สุ่มคีย์
function generateKey() {
    const prefix = "HXH";
    const random = Math.random().toString(36).substring(2, 10).toUpperCase();
    return `${prefix}-${random}`;
}

// 🟢 CREATE KEY
app.get('/api/create', (req, res) => {
    const { userid } = req.query;

    if (!userid) {
        return res.status(400).json({ error: "ต้องมี userid" });
    }

    if (hasRecentKey(userid)) {
        return res.status(429).json({ error: "สร้างได้วันละครั้ง" });
    }

    const key = generateKey();

    keysDatabase.push({
        userId: userid,
        key: key,
        time: new Date().toISOString()
    });

    res.json({
        key: key,
        expireIn: 86400
    });
});

// 🔵 VALIDATE
app.get('/api/validate', (req, res) => {
    const { key, userid } = req.query;

    if (!key || !userid) {
        return res.status(400).json({ valid: false });
    }

    const found = keysDatabase.find(k => k.key === key);

    if (!found) return res.json({ valid: false });
    if (found.userId !== userid) return res.json({ valid: false });

    const diff = (Date.now() - new Date(found.time)) / (1000 * 60 * 60);

    if (diff >= 24) return res.json({ valid: false });

    res.json({ valid: true });
});

// 🧪 TEST ROUTE
app.get('/', (req, res) => {
    res.send("API RUNNING");
});

// 🚀 START
app.listen(PORT, () => {
    console.log("Server running on port " + PORT);
});
