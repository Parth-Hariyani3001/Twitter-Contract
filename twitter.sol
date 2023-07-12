// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Twitter{

    //tweet struct
    struct Tweet{
        uint id;
        address author;
        string content;
        uint createdAt;
    }

    //message struct
    struct Message{
        uint id;
        string content;
        address from;
        address to;
        uint createdAt;
    }

    //mapping to store the tweets
    mapping(uint => Tweet) private tweets;

    //mapping to store id of the tweet of the individual user -> ex: 0xabc -> [2,4,6]
    mapping(address => uint[]) public tweetsOf;

    //mapping to store the conversations i.e messages 
    mapping(address => Message[]) public conversations;

    //mapping to store the addresses that are allowed by the owner to operate owner's address for conversation and tweet
    mapping(address => mapping(address => bool)) public operators;

    //mapping to store the list of following
    mapping(address => address[]) public following;

    uint public nextId; //Used to track tweet id
    uint public nextMessageId;  //used to track message id

    //To store the tweet
    function _tweet(address _from,string memory _content) internal {
        require(_from == msg.sender || operators[_from][msg.sender],"You don't have access");
        tweets[nextId] = Tweet(nextId,_from,_content,block.timestamp);
        tweetsOf[_from].push(nextId);
        nextId++;
    }

    //To store messages
    function _sendMessage(address _from,address _to,string memory _content) internal {
        require(_from==msg.sender || operators[_from][msg.sender],"You don't have access");
        conversations[_from].push(Message(nextMessageId,_content,_from,_to,block.timestamp));
        nextMessageId++;
    }

    //owner making the tweet
    function tweet(string memory _content) public{
        _tweet(msg.sender, _content);
    }

    //Someone who has the permission from the owner to access to make the tweet
    function tweet(address _from,string memory _content) public {
        _tweet(_from, _content);
    }

    //owner sending the message
    function sendMessage(address _to, string memory _content) public{
        _sendMessage(msg.sender, _to, _content);
    }

    //Someone who has the permission from the owner to access to send the message
    function sendMessage(address _from,address _to,string memory _content) public{
        _sendMessage(_from, _to, _content);
    }

    //To follow someone
    function follow(address _followed) public{
        following[msg.sender].push(_followed);
    }

    //To give someone the access to make tweets or messages
    function allow(address _operator) public{
        operators[msg.sender][_operator] = true;
    }

    //To revoke the acces from someone to make tweets or messages
    function disallow(address _operator) public{
        operators[msg.sender][_operator] = false;
    }

    //To get the latest tweets
    function getLatestTweets(uint count) public view returns(Tweet[] memory){
        require(count > 0 && count <= nextId,"Count is not proper");
        Tweet[] memory _tweets = new Tweet[](count);    //array length -> count
        //as mapping are not iterable so we create an array
        uint j;


        for(uint i = nextId-count;i < nextId; i++){
            Tweet storage _structure = tweets[i];
            _tweets[j] = Tweet(_structure.id,_structure.author,_structure.content,_structure.createdAt);
            j = j + 1;
        }

        return _tweets;
    }

    //To get the latest tweets of a particular user
    function getLatestofUser(address _user,uint count) public view returns(Tweet[] memory){
        uint[] memory userIDTweets = tweetsOf[_user];
        Tweet[] memory _tweets = new Tweet[](count);    //array length -> count
        //as mapping are not iterable so we create an array
        uint lengthOfUserTweets = tweetsOf[_user].length;
        require(count > 0 && count <= nextId,"Count is not defined");
        uint j;
        for(uint i = lengthOfUserTweets - count; i < lengthOfUserTweets; i++){
            Tweet storage _structure = tweets[userIDTweets[i]]; //ex:- i = 2 id[2] = 15 tweets[15]
            _tweets[j] = Tweet(_structure.id,
            _structure.author,
            _structure.content,
            _structure.createdAt);
            j = j + 1;
        }
        return _tweets;
    }
}