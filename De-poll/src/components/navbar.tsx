import { Link } from "react-router-dom";

export default function Navbar() {
    return (
        <div>
            <nav>
                <Link to='/'>
                    <p>home icon</p>
                    <p>Home</p>
                </Link>
                <Link to='/elections'>
                    <p>poll icon</p>
                    <p>Elections</p>
                </Link>
                <Link to='/new'>
                    <p>new icon</p>
                    <p>New</p>
                </Link>
                <Link to='/games'>
                    <p>game icon</p>
                    <p>Games</p>
                </Link>
                <Link to='/user'>
                    <p>user icon</p>
                    <p>User</p>
                </Link>
            </nav>
        </div>
    )
}