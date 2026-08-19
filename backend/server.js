const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");
const axios = require("axios");
require("dotenv").config();

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const COUNTRIES_API_URL = "https://countriesnow.space/api/v0.1/countries/capital";

app.get("/api/health", (req, res) => {
  res.status(200).json({ status: "ok", message: "Dream Vacations API is running" });
});

app.get("/api/destinations", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM destinations ORDER BY id DESC");
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/api/destinations", async (req, res) => {
  const { country } = req.body;

  if (!country || country.trim() === "") {
    return res.status(400).json({ error: "Country name is required" });
  }

  try {
    const response = await axios.get(COUNTRIES_API_URL, { timeout: 8000 });
    const countries = response.data.data;

    const countryInfo = countries.find(
      (c) => c.name.toLowerCase() === country.trim().toLowerCase()
    );

    if (!countryInfo) {
      return res.status(404).json({ error: `Country "${country}" not found. Check spelling and try again.` });
    }

    const capital = countryInfo.capital || "N/A";
    const region = countryInfo.iso2 || "Unknown";

    const result = await pool.query(
      "INSERT INTO destinations (country, capital, population, region) VALUES ($1, $2, $3, $4) RETURNING *",
      [countryInfo.name, capital, 0, region]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.delete("/api/destinations/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query("DELETE FROM destinations WHERE id = $1", [id]);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
