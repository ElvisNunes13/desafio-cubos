import http from 'http';
import PG from 'pg';

const {
  PORT = 3001,
  POSTGRES_USER,
  POSTGRES_PASSWORD,
  POSTGRES_HOST,
  POSTGRES_PORT,
  POSTGRES_DB
} = process.env;

const client = new PG.Client({
  user: POSTGRES_USER,
  password: POSTGRES_PASSWORD,
  host: POSTGRES_HOST,
  port: POSTGRES_PORT,
  database: POSTGRES_DB
});

let successfulConnection = false;

async function connectDB() {
  try {
    await client.connect();
    successfulConnection = true;
    console.log("Database connected");
  } catch (err) {
    console.error("Database not connected -", err.stack);
  }
}
connectDB();

http.createServer(async (req, res) => {
  console.log(`Request: ${req.url}`);

  if (req.url === "/api") {
    res.setHeader("Content-Type", "application/json");
    res.writeHead(200);

    let result;

    try {
      result = (await client.query("SELECT * FROM users")).rows[0];
    } catch (error) {
      console.error(error);
    }

    const data = {
      database: successfulConnection,
      userAdmin: result?.role === "admin"
    };

    res.end(JSON.stringify(data));
  } else {
    res.writeHead(404);
    res.end("Not Found");
  }

}).listen(PORT, () => {
  console.log(`Server is listening on port ${PORT}`);
});
