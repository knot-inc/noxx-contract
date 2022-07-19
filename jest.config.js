module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  testMatch: ["**/*.test.ts"],
  transform: {
    "^.+\\.tsx?$": "ts-jest",
  },
  roots: ["<rootDir>"],
  projects: ["<rootDir>"],
};