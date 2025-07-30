const { run } = require("hardhat");

async function main() {
    const contracts = [
        {
        name: "Token",
        address: "0x1a63Bf84eB01b40275cbbeCFC2Fc55933c1f839E",
        args: ["0xA26EE8c6c46E9267cf0b9f7c2dE0EbB7AddfaD8F"] // Owner address
        },
        {
        name: "Notifications",
        address: "0x30407C90fD31b2d5696a8E75f19D487Cf0762b10",
        args: [] // No constructor arguments
        },
        {
        name: "Payments",
        address: "0x74D6116eA81Ec5e3491d56C195fb74E3ba599778",
        args: [
            "0x1a63Bf84eB01b40275cbbeCFC2Fc55933c1f839E", // Token address
            "0x30407C90fD31b2d5696a8E75f19D487Cf0762b10", // Notifications address
            "0xA26EE8c6c46E9267cf0b9f7c2dE0EbB7AddfaD8F"  // Owner address
        ]
        },
        {
        name: "UserContract",
        address: "0x18cF54e1F81BB16dE5e622b3Bc12CEE5cc2eD207",
        args: [
            "0x74D6116eA81Ec5e3491d56C195fb74E3ba599778", // Payments address
            "0x30407C90fD31b2d5696a8E75f19D487Cf0762b10"  // Notifications address
        ]
        },
        {
        name: "GameContract",
        address: "0xD39c0289064C587a9ab5f991df48bF9EBFdb24ac",
        args: [
            "0xA26EE8c6c46E9267cf0b9f7c2dE0EbB7AddfaD8F", // Owner address
            "0x30407C90fD31b2d5696a8E75f19D487Cf0762b10"  // Notifications address
        ]
        },
        {
        name: "Leaderboard",
        address: "0x744B80721E9EBD0e9663Add8eb376BD00f7307B5",
        args: [
            "0xA26EE8c6c46E9267cf0b9f7c2dE0EbB7AddfaD8F", // Owner address
            "0xD39c0289064C587a9ab5f991df48bF9EBFdb24ac"  // GameContract address
        ]
        },
        {
        name: "Election",
        address: "0xCdcec64E8E79133923C24d131AAd70a2eC926FB0",
        args: [
            "0x30407C90fD31b2d5696a8E75f19D487Cf0762b10", // Notifications address
            "0x74D6116eA81Ec5e3491d56C195fb74E3ba599778", // Payments address
            "0x18cF54e1F81BB16dE5e622b3Bc12CEE5cc2eD207", // UserContract address
            "0x1a63Bf84eB01b40275cbbeCFC2Fc55933c1f839E"  // Token address
        ]
        }
    ];

    console.log("Starting verification process...");
    
    for (const contract of contracts) {
        try {
            console.log(`\nVerifying ${contract.name} at ${contract.address}...`);
            await run("verify:verify", {
                address: contract.address,
                constructorArguments: contract.args,
            });
            console.log(`✅ ${contract.name} verified successfully`);
        } catch (error) {
            if (error.message.includes("Already Verified")) {
                console.log(`🔹 ${contract.name} already verified`);
            } else {
                console.log(`⚠️  ${contract.name} verification failed:`, error.message.split('\n')[0]);
            }
        }
        await new Promise(resolve => setTimeout(resolve, 2000)); // 2s delay between verifications
    }

    console.log("\nVerification process completed!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });