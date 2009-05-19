Johnson.require(Ruby.File.dirname(__FILE__)+"/test_helper")

var eventJSON = [
    { id: 1,
      type: "AllDay",
      creator_id: 1,
      name: "Vacation",
      start_date: "2009-04-15",
      start_time: "8:00",
      end_date: "2009-04-18",
      end_time: "17:00",
      remind: 0
    },
    { id: 2,
      type: "Appointment",
      creator_id: 1,
      name: "Meeting with staff at the office",
      start_date: "2009-04-15",
      start_time: "13:30",
      end_date: "2009-04-15",
      end_time: "15:00",
      remind: 0
    },
    { id: 3,
      type: "Task",
      creator_id: 1,
      name: "Clean the office",
      start_date: "2009-04-15",
      remind: 1
    },
    { id: 4,
      type: "Deadline",
      creator_id: 1,
      name: "File papers at Courthouse",
      start_date: "2009-04-15",
      start_time: "12:00",
      remind: 1
    }
  ]
// mock the json response
$ = {
  getJSON: function(url, args, callback){
    callback(eventJSON) // see bottom of file for helper definition
  }
}

jspec.describe("Event", function() {

  it("should find by id", function() {
    expect(Event.find(4)).to("==", eventJSON[3]);
  });
});

