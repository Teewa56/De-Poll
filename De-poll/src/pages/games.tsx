import { Link } from "react-router-dom"

const Games = () => {
  return (
    <div>
        <h3>Games</h3>
        <p>Play to earn onchain and also feel the vibe of online betting</p>
        <div>
            <div>
                <img src="/logo" alt="" />
                <h3>Cash Flow</h3>
                <p>Play cash flow with others to know how good you are with finances and money</p>
                <Link to='/games/cashFlow'>Play now</Link>
            </div>
            <div>
                <img src="/logo" alt="" />
                <h3>Inj or Dead</h3>
                <p>Play injured or dead with other to test how good you are with reasoning and also with your thinking abilities</p>
                <Link to='/games/InjorDead'>Play now</Link>
            </div>
            <div>
                <img src="/logo" alt="" />
                <h3>Cash Flow</h3>
                <p>How good are you with the blockchain, explore the metaverse with satoshi and see how cool and best you can earn from his digital village</p>
                <Link to='/games/satoshiGame'>Play now</Link>
            </div>
        </div>
    </div>
  )
}

export default Games