import { Link } from "react-router-dom"
import { useEffect, useMemo, useState } from "react"
//show user around when he first opens the app
//click on any of the elctions on the homepage to go the election page
//grid display for the elections
//lasy load the boxes here to display a glass box

type electionProps = {
    electionId: string;
    electionName: string;
    candidateNames: string[];
}

export default function HomePage(){
    const [ongoingELections, setOngoingElections] = useState<electionProps[]>([]);
    const [topElections, settopElections] = useState<electionProps[]>([]);
    const [finishedElections, setfinishedElections] = useState<electionProps[]>([]);    
    const [forYou, setforYou] = useState<electionProps[]>([]);
    const address = localStorage.getItem('address');
    const walletAddress = useMemo(() => (address), [address]) 

    useEffect(() => {
        async function fetchElections(){
            try {
                const ongoinfRes = await fetchOngoingElections(walletAddress);
                setOngoingElections(ongoinfRes.data.ongoingELections);
                const topRes = await fetchTopElections(walletAddress);
                settopElections(topRes.data.topElections);  
                const finishedRes = await fetchOngoingElections(walletAddress);
                setfinishedElections(finishedRes.data.ongoingELections);
                const foryouRes = await fetchTopElections(walletAddress);
                setforYou(foryouRes.data.topElections);                
            } catch (error) {
                return error instanceof Error 
                &&  console.log('error from fetching data',error);
            }
        }
        fetchElections();
    }, [walletAddress])

    return(
        <>
            <div className="page">
                <div className="header">
                    <div className="hs1" >
                        <img src="/images" alt="/profilePic" />
                        <div>
                            <p>username</p>
                            <p>wallet address</p>
                        </div>
                    </div>
                    <div className="hs2" >
                        <p>NotificationIcon</p>
                    </div>
                </div>
                <div>
                    <p>Good day {user}, have a nice time here</p>
                    <div>
                        <p>Wallet: <span>{walletAddress}</span></p>
                        <div>
                            <p>Balance: <span>{walletBalance}</span></p>
                            <p>Picture to show Balance or not</p>
                        </div>
                    </div>
                </div>
                <div>
                    <h3>For you</h3>
                    {forYou.length > 0 ? 
                        forYou.map((election) => (
                            <Link to={`/electionPage/${election?.electionId}`} >
                                <div key={election.electionId} >
                                    <img src="poll image" alt="" />
                                    <p>Poll Name: {election.electionName}</p>
                                    <p>No of candidates: {election.candidateNames.length}</p>
                                </div>
                            </Link>
                        )) : <p>You haven't been added to partcipate in any elections yet!</p>
                    }
                </div>
                <div>
                    <h3>Ongoing elections</h3>
                    {ongoingELections.length > 0 ?  
                        ongoingELections.map((election) => (
                            <Link to={`/electionPage/${election.electionId}`} >
                                <div key={election.electionId} >
                                    <img src="poll image" alt="" />
                                    <p>Poll Name: {election.electionName}</p>
                                    <p>No of candidates: {election.candidateNames.length}</p>
                                </div>
                            </Link>
                    )) : <p>No ongoing elections yet!</p> }
                </div>
                <div>
                    <h3>Top elections</h3>
                    {topElections.length > 0 ? 
                        topElections.map((election) => (
                            <Link to={`/electionPage/${election.electionId}`} >
                                <div key={election.electionId} >
                                    <img src="poll image" alt="" />
                                    <p>Poll Name: {election.electionName}</p>
                                    <p>No of candidates: {election.candidateNames.length}</p>
                                </div>
                            </Link>
                    )) : <p>Nothing here yet</p> }
                </div>
                <div>
                    <h3>Ongoing elections</h3>
                    {finishedElections.length > 0 ?
                        finishedElections.map((election) => (
                            <Link to={`/electionPage/${election.electionId}`} >
                                <div key={election.electionId} >
                                    <img src="poll image" alt="" />
                                    <p>Poll Name: {election.electionName}</p>
                                    <p>No of candidates: {election.candidateNames.length}</p>
                                </div>
                            </Link>
                    )) : <p>Nothing here, note that your finished elections are removed after 24hours</p> }
                </div>
            </div>
        </>
    )
}