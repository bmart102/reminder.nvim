local M = {}
M.timer = nil
local DEFAULT_INTERVAL = 5000
local DEFAULT_MSG = "Hello from Reminder plugin!"
local init_interval
local init_message
local window_id = nil

local close_reminder = function()
	if window_id then
		vim.api.nvim_win_close(window_id, true)
		window_id = nil
	end
end

local pop_message = function(msg)
	-- 1. Create an empty "scratch" buffer (not saved to a file)
	local buf = vim.api.nvim_create_buf(false, true)

	-- 2. Set some text inside that buffer
	-- vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  Hello World!  ", "  This is a Pop-up  " })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { msg })

	-- 3. Define where the window should appear
	local win_opts = {
		relative = "editor", -- Position relative to the whole editor screen
		width = 30,
		height = 2,
		row = 10, -- Rows from the top
		col = 10, -- Columns from the left
		style = "minimal", -- No numbers or status lines
		border = "rounded", -- Options: "none", "single", "double", "rounded", "solid", "shadow"
		title = "reminder",
	}

	close_reminder()
	-- The 'false' means "don't jump my cursor into the popup"
	window_id = vim.api.nvim_open_win(buf, false, win_opts)
end

local stop_reminder = function()
	if M.timer then
		M.timer:stop()
		M.timer:close()
		M.timer = nil
		close_reminder()
		print("Reminder stopped.")
	end
end

local start_reminder = function(opts)
	-- Stop existing timer if it's already running to prevent duplicates
	stop_reminder()

	opts = opts or {}
	local interval = opts.interval or init_interval
	local message = opts.message or init_message
	print(interval)
	print(message)

	M.timer = vim.loop.new_timer()
	M.timer:start(
		interval,
		interval,
		vim.schedule_wrap(function()
			pop_message(message)
		end)
	)

	--for neovim 0.11.5
	-- local timer = vim.uv.new_timer()
	--
	-- -- timer:start(delay, repeat, callback)
	-- timer:start(
	-- 	5000,
	-- 	0,
	-- 	vim.schedule_wrap(function()
	-- 		print("5 second has passed.")
	-- 		timer:stop()
	-- 		timer:close()
	-- 	end)
	-- )
	print("Reminder started.")
end

function M.setup(opts)
	print("Reminder initialized")
	opts = opts or {}
	init_interval = opts.interval or DEFAULT_INTERVAL
	init_message = opts.message or DEFAULT_MSG

	vim.api.nvim_create_user_command("ReminderStart", function(opts)
        opts = opts or {}
		local interval = opts.fargs[1] and tonumber(opts.fargs[1]) or init_interval
		local message = opts.fargs[2] and table.concat(opts.fargs, " ", 2) or init_message
		start_reminder({ interval = interval, message = message })
	end, {
		nargs = "*", -- '*' means any number of arguments
		desc = "Start the reminder with: :Reminder [ms] [message]",
	})
	vim.api.nvim_create_user_command("ReminderStop", function()
		stop_reminder()
	end, {})
	vim.api.nvim_create_user_command("ReminderCloseWndw", function()
		close_reminder()
	end, {})
end

return M
