import { useState } from "react";

const Toast = ({text}) => {
    const [text, setText] = useState<null | string>(null);
    setInterval(() => {
        if(text) setText(null)
    }, 7000)
    return (
        <div className="border rounded-lg p-3 bg-green-400 text-black h-20 fade" >
           <p>{text}</p> 
        </div>
    )
}

export default Toast;