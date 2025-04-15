// import { useEffect } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Welcome from "./authPages/welcome";
import CreateAccount from './authPages/createAccount';
import HomePage from './pages/homePage';
import Navbar from './components/navbar';
import ElectionPage from './pages/electionPage';
import ElectionsPage from './pages/electionsPage';
import Games from './pages/games';
import NewElection from './pages/newElection';
import './App.css';
//here switch based on the value stored in the local storage and also use protectedroutes
//to check if the user has an account before he can use some services on the app
//what if the user is signing on another device
//enable user to delete and election
export default function App() {
  // const  token = localStorage.getItem('address');
  // useEffect(() => {
  //   if(token){
  //     setHasAccount
  //   }
  // },[token])
  return(
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Welcome/>}/>
        <Route path="/createAccount" element={<CreateAccount/>}/>
        <Route path='/home' element={<HomePage />}/>
        <Route path="/elections" element={<ElectionsPage/>}/>
        <Route path="/elections/:electionId" element={<ElectionPage/>}/>
        <Route path='/games' element={<Games />} />
        <Route path='/new' element={<NewElection />}/>
      </Routes>
      <Navbar />
    </BrowserRouter>
  )
}