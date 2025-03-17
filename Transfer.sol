pragma solidity ^ 0.8.19;

contract Transfer
{
	function transfer(address payable to)
	external payable
	{
		to.transfer(msg.value);
	}
}