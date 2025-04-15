import { useState } from 'react'
//get all ongoing elections from the contract
const ElectionsPage = () => {
    const [ongoingElections, setongoingElections] = useState([]);
    return (
        <div>
            <div>
                <p>Ongoing elections</p>
            </div>
            {ongoingElections.length > 0 ? 
                ongoingElections.map((election) => {
                    <div key={election.electionId} >
                        <img src="/image of poll" alt="" />
                        <div>
                            <p>number of voters</p>
                            <p>no of candidates</p>
                            <p>time and anu=y other information concerning the poll</p>
                        </div>
                    </div>
                }) : <p>Nothing here yet</p>
            }
            <div><p>copyright@{new Date().getFullYear()}</p></div>
        </div>
    )
}

export default ElectionsPage