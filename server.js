function generateKey() {
    const types = ["ALPHA", "BETA", "GAMMA", "OMEGA"];
    
    const randomType = types[Math.floor(Math.random() * types.length)];

    const part1 = Math.floor(1000 + Math.random() * 9000); // 4 หลัก
    const part2 = Math.floor(1000 + Math.random() * 9000); // 4 หลัก

    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const part3 =
        letters[Math.floor(Math.random() * letters.length)] +
        letters[Math.floor(Math.random() * letters.length)] +
        Math.floor(10 + Math.random() * 90); // เช่น AB12

    return `DX-${randomType}-${part1}-${part3}`;
}
