// Interface:
// 
// Event.find(4)
//   # returns a single event object
// Event.find({tags: ["one", "two"]})
//   # returns all events matching tags
//   # defaults to timeframe of one month past and one month future
// Event.find({start: '2009-03-04', end: '2009-08-09'})
//   # returns all events in the given timeframe
// Event.find({tags: ["one", "two"],
//             start: '2009-03-04',
//             end: '2009-08-09'})
//   # returns events matching all given criteria
//   # Event.find calls:
//   Event.retrieve(arguments)
//     # which calls via callback:
//     Event.instantiate(events)
//       # adds helpful event methods to the json object's prototype