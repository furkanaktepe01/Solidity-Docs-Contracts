// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract Ballot {

    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) {

        chairperson = msg.sender;

        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {

            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Possible Improvements
    function giveRightToVote(address voter) internal {

        require(!voters[voter].voted);

        require(voters[voter].weight == 0);

        voters[voter].weight = 1;
    }

    function delegate(address to) external {

        Voter storage sender = voters[msg.sender];

        require(!sender.voted);

        require(to != msg.sender);

        while (voters[to].delegate != address(0)) {
            
            to = voters[to].delegate;
            
            require(to != msg.sender);
        }

        Voter storage delegate_ = voters[to];

        require(delegate_.weight != 0);

        sender.voted = true;

        sender.delegate = to;

        if (delegate_.voted) {
            
            proposals[delegate_.vote].voteCount += sender.weight;
        
        } else {

            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) external {

        Voter storage sender = voters[msg.sender];

        require(sender.weight != 0);

        require(!sender.voted);

        sender.voted = true;

        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint winningProposal_) {
        
        uint winningVoteCount = 0;
    
        for (uint p = 0; p < proposals.length; p++) {
            if (proposal[p].voteCount > winningVoteCount) {
                winningVoteCount = proposal[p].voteCount;
                winningProposal_= p;
            }
        }
    }

    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }

    // Possible Improvements
    function giveRightsToVote(address[] voters) external {
        
        require(msg.sender == chairperson);

        for (uint i = 0; i < voters.length; i++) {
            giveRightToVote(voters[i]);
        }
    }

}
