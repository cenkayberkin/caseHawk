/**
* The datemath module provides utility methods for basic JavaScript Date object manipulation and
* comparison.
*
* Taken form YUI version 2
* http://github.com/yui/yui2/raw/master/src/datemath/js/DateMath.js
*/

// YAHOO.widget.DateMath = {
DateMath = {
    DAY : "D",
    WEEK : "W",
    YEAR : "Y",
    MONTH : "M",
    ONE_DAY_MS : 1000*60*60*24,
    WEEK_ONE_JAN_DATE : 1,

    add : function(date, field, amount) {
        var d = new Date(date.getTime());
        switch (field) {
            case this.MONTH:
                var newMonth = date.getMonth() + amount;
                var years = 0;

                if (newMonth < 0) {
                    while (newMonth < 0) {
                        newMonth += 12;
                        years -= 1;
                    }
                } else if (newMonth > 11) {
                    while (newMonth > 11) {
                        newMonth -= 12;
                        years += 1;
                    }
                }

                d.setMonth(newMonth);
                d.setFullYear(date.getFullYear() + years);
                break;
            case this.DAY:
                this._addDays(d, amount);
                // d.setDate(date.getDate() + amount);
                break;
            case this.YEAR:
                d.setFullYear(date.getFullYear() + amount);
                break;
            case this.WEEK:
                this._addDays(d, (amount * 7));
                // d.setDate(date.getDate() + (amount * 7));
                break;
        }
        return d;
    },

    _addDays : function(d, nDays) {
        d.setDate(d.getDate() + nDays);
    },

    subtract : function(date, field, amount) {
        return this.add(date, field, (amount*-1));
    },

    before : function(date, compareTo) {
        var ms = compareTo.getTime();
        if (date.getTime() < ms) {
            return true;
        } else {
            return false;
        }
    },

    after : function(date, compareTo) {
        var ms = compareTo.getTime();
        if (date.getTime() > ms) {
            return true;
        } else {
            return false;
        }
    },

    between : function(date, dateBegin, dateEnd) {
        if (this.after(date, dateBegin) && this.before(date, dateEnd)) {
            return true;
        } else {
            return false;
        }
    },

    getJan1 : function(calendarYear) {
        return this.getDate(calendarYear,0,1);
    },

    getDayOffset : function(date, calendarYear) {
        var beginYear = this.getJan1(calendarYear); // Find the start of the year. This will be in week 1.

        // Find the number of days the passed in date is away from the calendar year start
        var dayOffset = Math.ceil((date.getTime()-beginYear.getTime()) / this.ONE_DAY_MS);
        return dayOffset;
    },

    getWeekNumber : function(date, firstDayOfWeek, janDate) {

        // Setup Defaults
        firstDayOfWeek = firstDayOfWeek || 0;
        janDate = janDate || this.WEEK_ONE_JAN_DATE;

        var targetDate = this.clearTime(date),
            startOfWeek,
            endOfWeek;

        if (targetDate.getDay() === firstDayOfWeek) {
            startOfWeek = targetDate;
        } else {
            startOfWeek = this.getFirstDayOfWeek(targetDate, firstDayOfWeek);
        }

        var startYear = startOfWeek.getFullYear();

        // DST shouldn't be a problem here, math is quicker than setDate();
        endOfWeek = new Date(startOfWeek.getTime() + 6*this.ONE_DAY_MS);

        var weekNum;
        if (startYear !== endOfWeek.getFullYear() && endOfWeek.getDate() >= janDate) {
            // If years don't match, endOfWeek is in Jan. and if the
            // week has WEEK_ONE_JAN_DATE in it, it's week one by definition.
            weekNum = 1;
        } else {
            // Get the 1st day of the 1st week, and
            // find how many days away we are from it.
            var weekOne = this.clearTime(this.getDate(startYear, 0, janDate)),
                weekOneDayOne = this.getFirstDayOfWeek(weekOne, firstDayOfWeek);

            // Round days to smoothen out 1 hr DST diff
            var daysDiff  = Math.round((targetDate.getTime() - weekOneDayOne.getTime())/this.ONE_DAY_MS);

            // Calc. Full Weeks
            var rem = daysDiff % 7;
            var weeksDiff = (daysDiff - rem)/7;
            weekNum = weeksDiff + 1;
        }
        return weekNum;
    },

    getFirstDayOfWeek : function (dt, startOfWeek) {
        startOfWeek = startOfWeek || 0;
        var dayOfWeekIndex = dt.getDay(),
            dayOfWeek = (dayOfWeekIndex - startOfWeek + 7) % 7;

        return this.subtract(dt, this.DAY, dayOfWeek);
    },

    isYearOverlapWeek : function(weekBeginDate) {
        var overlaps = false;
        var nextWeek = this.add(weekBeginDate, this.DAY, 6);
        if (nextWeek.getFullYear() != weekBeginDate.getFullYear()) {
            overlaps = true;
        }
        return overlaps;
    },

    isMonthOverlapWeek : function(weekBeginDate) {
        var overlaps = false;
        var nextWeek = this.add(weekBeginDate, this.DAY, 6);
        if (nextWeek.getMonth() != weekBeginDate.getMonth()) {
            overlaps = true;
        }
        return overlaps;
    },

    findMonthStart : function(date) {
        var start = this.getDate(date.getFullYear(), date.getMonth(), 1);
        return start;
    },

    findMonthEnd : function(date) {
        var start = this.findMonthStart(date);
        var nextMonth = this.add(start, this.MONTH, 1);
        var end = this.subtract(nextMonth, this.DAY, 1);
        return end;
    },

    clearTime : function(date) {
        date.setHours(12,0,0,0);
        return date;
    },


    getDate : function(y, m, d) {
        var dt = null;
        if (YAHOO.lang.isUndefined(d)) {
            d = 1;
        }
        if (y >= 100) {
            dt = new Date(y, m, d);
        } else {
            dt = new Date();
            dt.setFullYear(y);
            dt.setMonth(m);
            dt.setDate(d);
            dt.setHours(0,0,0,0);
        }
        return dt;
    }
};