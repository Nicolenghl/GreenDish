Problem 1: Movie Ticket Booking Smart Contract
Create a smart contract that allows users to book movie tickets, manage available seats, and handle payments. It will contain the following items.
1.  Define the Contract: o  Create a contract named MovieTicketBooking.
2.  State Variables:
o  Define the following state variables:
▪  string public movieName: The name of the movie. ▪  uint public ticketPrice: The price of each ticket. ▪  uint public totalSeats: The total number of seats available for the movie. ▪  uint public availableSeats: The number of available seats. ▪  mapping(address => uint) public ticketsBought: A mapping to track how many
tickets each user has purchased.
3.  Constructor:
o  Implement a constructor that initializes the movieName, ticketPrice, and totalSeats. Set
availableSeats equal to totalSeats.
4.  Functions:
o  buyTicket(uint _numberOfTickets):
▪  This function allows users to purchase tickets. ▪  Ensure that the number of tickets requested does not exceed the available seats. ▪  Calculate the total cost and require that the user sends enough Ether to cover the
purchase. ▪  Update the availableSeats and ticketsBought mapping accordingly. ▪  Emit an event called TicketPurchased that logs the buyer's address and the number
of tickets purchased.
o  getAvailableSeats():
▪  This function returns the number of available seats. o  getTotalTicketsBought(address _buyer):
▪  This function returns the number of tickets purchased by a specific address.
5.  Events:
o  Define an event called TicketPurchased with parameters for the buyer's address and the
number of tickets purchased.
6.  Error Handling:
o  Use require statements to ensure:
▪  The number of tickets requested does not exceed available seats. ▪  The user has sent enough Ether for the purchase.
Testing your contract and capturing the screen for the following actions: 1.  Deploy the Contract:
o  Deploy the MovieTicketBooking contract with a movie name, ticket price, and total
number of seats.
2.  Purchase Tickets:
o  Call the buyTicket function with different values to simulate purchasing tickets. Ensure
that the contract correctly updates the available seats and logs the purchases.
3.  Check Available Seats:
o  Use the getAvailableSeats function to verify the number of remaining seats after
purchases.
4.  Check Tickets Bought:
o  Use the getTotalTicketsBought function to check how many tickets a specific address
has purchased.
