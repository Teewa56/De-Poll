import { useState } from "react";
//npm i uuid;
//use uuid here when sending a request to the smart contract as the electionId
//two users cannot have the same name when signing up
//ask if user wants to discard election or not if the user already made some add to the election
const NewElection = () => {
    const [pollName, setPollName] = useState("");
    const [allUsers, setAllUsers] = useState([]);
    const [candidatesNames, setCandidatesNames] = useState([]);
    const [candidateName, setCandidateNames] = useState('');
    return (
        <div>
            <div className="head">
                <p>back button</p>
                <h2>New</h2>
            </div>
            <div>
                <form onSubmit={hanadleSubmit}>
                    <label>
                        <p>Election Name</p>
                        <input type="text" value={pollName}
                            onChange={(e) => setPollName(e.target.value)} 
                            placeholder="Poll Name here..."/>
                    </label>
                    <p>Calendar and clock to out in close time and convert it to milliseconds using a function</p>
                    <label>
                        <p>Candidates Names</p>
                        <input type="text" value={candidateName}
                            onChange={(e) => setCandidatesNames(...candidatesNames, e.target.value)}/>
                    </label>
                    {candidatesNames.map((candidate, index) => {
                        <div key={index} >
                            <img src="/profile pic of candidate when inputing his name" alt=""/>
                            <p>{candidate.candidateName}</p>
                        </div>{/*automatically fetch the users information when a new user is added to the list*/}
                    })}
                    <p>Do same from above for the allowed voters</p>
                    <button>Create Election</button>
                </form>
            </div>
        </div>
    )
}

export default NewElection