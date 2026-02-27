Simple reminder plugin that creates a floating window when timer is triggered.

{
    "bmart102/reminder.nvim",
	  cmd = "ReminderStart",
	  config = function()
		  require("reminder").setup({ 
        interval = 600000, --will trigger every interval (in milliseconds) 
        message = "hello world" --message that will appear in the floating window
      })
	  end,
}

