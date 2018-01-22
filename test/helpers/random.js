// Returns a random number between 0 and max
export default function randomInt(max) {
  return Math.floor(Math.random() * Math.floor(max)) || 1;
}
