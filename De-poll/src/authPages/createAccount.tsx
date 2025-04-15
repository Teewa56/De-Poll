//npm i react-intersection-observer
import { useState } from "react";
import axios from "axios";
import { useInview } from 'react-intersection-observer';
import Toast from './toast';
//store a value in the localstorage that automatically logs user in after initial signing up
//and manage with the use of a context
const CreateAccount = () => {

    const [userAddress, setUserAddress] = useState("");
    const [userName, setUserName] = useState("");
    const [imageUrl, setImageUrl] = useState<null | string>(null)
    const [Avatar, setAvatar] = useState<null | string>("");
    const [error, setError] = useState<null | string>(null);
    const images = [
        {alt : "Smallie", src : '/assets/images/jpg1.jpg'},
        {alt : "Smallie", src : '/assets/images/jpg1.jpg'},
        {alt : "Smallie", src : '/assets/images/jpg1.jpg'},
        {alt : "Smallie", src : '/assets/images/jpg1.jpg'},
        {alt : "Smallie", src : '/assets/images/jpg1.jpg'},
        {alt : "Smallie", src : '/assets/images/jpg1.jpg'},
        {alt : "Smallie", src : '/assets/images/jpg1.jpg'},
    ]

    const uploadImage = async () => {
        if(!Avatar) return;
        const formData = new FormData();
        formData.append('file', Avatar);
        formData.append('upload_preset', 'pymeet');
        try{
            const res = await axios.post(`https://api.cloudinary.com/v1_1/${import.meta.env.VITE_CLOUDINARY_CLOUD_NAME}/image/upload`,
            formData)
            setImageUrl(res.data.secure_url)
        }catch(err: unknown){
            setError(err.res?.message || err.message);
        }
    };

    const handleConnectWallet = async () => {

    }

    return(
        <div className="is-fullheight m-2 " >
            {}
            <p>Welcome, lets set up your account</p>
            <div>
                <label htmlFor="userName">
                    <input type="text" id="userName" value={userName} 
                        onChange={(e) => setUserName(e.target.value)}/>
                </label>
                <label htmlFor="avatar">
                    <h3>Avatar</h3>
                    <div className="is-flex is-flex-direction-column gap-20" >
                        {images.map((image, index) => {
                            const {ref, inView} = useInview({
                                threshold : 0.5,
                                onchange: (inView) => {
                                    if(inView) setAvatar(image.src);
                                },
                            });  
                            return(
                                <div key={index} onClick={() => setAvatar(image.src)}>
                                    <img src={image.src} 
                                    alt={`image for ${image.alt}`}
                                    ref={ref} 
                                    style={{
                                        scale: inView ? 1.5 : 1,
                                        width:'300px', height: '300px', 
                                        border: inView ? '5px solid blue' : 'none', 
                                        transition: 'border 0.4s ease'
                                    }}/>
                                    <p>{image.alt}</p>
                                </div>
                            )
                        })}
                    </div>
                </label>
                <button onClick={handleConnectWallet} >Connect Wallet</button>
            </div>
        </div>
    )
}

export default CreateAccount;