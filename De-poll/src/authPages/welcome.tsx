//npm install swiper
import {Swiper, SwiperSlide} from 'swiper/react';
import 'swiper/swiper-bundle.min.css';
import 'swiper/css/pagination';
import {Pagination} from 'swiper';
import {Link} from 'react-router-dom';

const Welcome = () => {
    return (
        <div className="m-2 is-full-height is-flex is-justify-content-center is-allign-items-center">
            <div className="is-fullwidth  is-halfheight ">
                <h3 className="is-size-1 has-text-centered has-text-weight-bold" >De-Poll</h3> 
                <Swiper 
                    modules = {[Pagination]}
                    spaceBetween = {50} 
                    slidesPreview = {1} 
                    navigation 
                    pagination ={{ 
                        clickable : true,
                        renderBullet  : (index: number, className: string) => {
                            return `<span class='${className} custom-bullet'>${index + 1} </span>`
                        }
                    }}
                    loop = {true}>
                    <SwiperSlide>
                        <div>
                            <img src="" alt="" />
                            <p>Welcome to De-Poll!, cast your votes onchain</p>
                        </div>
                    </SwiperSlide>
                    <SwiperSlide>
                        <div>
                            <img src="" alt="" />
                            <p>Take voting to the next level through the use of the blockchain</p>
                        </div>
                    </SwiperSlide>
                    <SwiperSlide>
                        <div>
                            <img src="" alt="" />
                            <p>Create An account now to get Started</p>
                            <p>To get started you must have a metamask wallet installed, get from either apple strore, playstore or the web</p>
                            <Link to="/createAccount" className='button is-success is-medium mx-auto'>Get started</Link>
                        </div>
                    </SwiperSlide>
                </Swiper>
            </div>          
        </div>
    )
}

export default Welcome;