
_G.love = require("love")

local windowWidth, windowHeight = 600, 600
local cellSize = windowWidth / 9

local colors = {
    background = {0, 0, 0},
    lines = {1, 1, 1},
    xColor = {1, 0, 0},
    oColor = {0, 0, 1},
}


local currentPlayer = "X"
local mainBoard = {}
local mainBoardStatus = {}
local gameWon = false


local function newBoard()
    local board = {}
    for i = 1, 3 do
        board[i] = {}
        for j = 1, 3 do
            board[i][j] = " "
        end
    end
    return board
end

local function resetGame()
    mainBoard = {{newBoard(), newBoard(), newBoard()},
                 {newBoard(), newBoard(), newBoard()},
                 {newBoard(), newBoard(), newBoard()}}
    mainBoardStatus = newBoard()
    currentPlayer = "X"
    gameWon = false
end


local function checkWin(board, player)
    for i = 1, 3 do
        if (board[i][1] == player and board[i][2] == player and board[i][3] == player) or
           (board[1][i] == player and board[2][i] == player and board[3][i] == player) then
            return true
        end
    end
    if (board[1][1] == player and board[2][2] == player and board[3][3] == player) or
       (board[1][3] == player and board[2][2] == player and board[3][1] == player) then
        return true
    end
    return false
end


local function isBoardFull(board)
    for i = 1, 3 do
        for j = 1, 3 do
            if board[i][j] == " " then
                return false
            end
        end
    end
    return true
end


local function handleMouseClick(x, y)
    if gameWon then return end

    -- Determine which main and sub-board the click is in
    local mainRow = math.floor(y / (cellSize * 3)) + 1
    local mainCol = math.floor(x / (cellSize * 3)) + 1

    local subRow = math.floor((y % (cellSize * 3)) / cellSize) + 1
    local subCol = math.floor((x % (cellSize * 3)) / cellSize) + 1

    if mainBoardStatus[mainRow][mainCol] == " " and mainBoard[mainRow][mainCol][subRow][subCol] == " " then
        -- Make the move
        mainBoard[mainRow][mainCol][subRow][subCol] = currentPlayer

        -- Check if the player won the sub-board
        if checkWin(mainBoard[mainRow][mainCol], currentPlayer) then
            mainBoardStatus[mainRow][mainCol] = currentPlayer
            -- Check if the player won the main game
            if checkWin(mainBoardStatus, currentPlayer) then
                gameWon = true
            end
        elseif isBoardFull(mainBoard[mainRow][mainCol]) then
            mainBoardStatus[mainRow][mainCol] = "D"  -- Mark as Draw
        end

        local tmp = " "
        if currentPlayer == "X" then
            tmp = "O"
        end
        if currentPlayer == "O" then
            tmp = "X"
        end
        currentPlayer = tmp
    end
end

-- Drawing function for a single board
local function drawBoard(board, offsetX, offsetY)
    for i = 1, 3 do
        for j = 1, 3 do
            local x = offsetX + (j - 1) * cellSize
            local y = offsetY + (i - 1) * cellSize
            love.graphics.rectangle("line", x, y, cellSize, cellSize)

            -- Draw X or O in the cell
            local mark = board[i][j]
            if mark == "X" then
                love.graphics.setColor(colors.xColor)
                love.graphics.line(x + 10, y + 10, x + cellSize - 10, y + cellSize - 10)
                love.graphics.line(x + 10, y + cellSize - 10, x + cellSize - 10, y + 10)
            elseif mark == "O" then
                love.graphics.setColor(colors.oColor)
                love.graphics.circle("line", x + cellSize / 2, y + cellSize / 2, cellSize / 2 - 10)
            end
            love.graphics.setColor(colors.lines)
        end
    end
end


function love.load()
    love.window.setTitle("Iks Oks")
    love.window.setMode(windowWidth, windowHeight)
    resetGame()
end


function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        handleMouseClick(x, y)
    end
end

function love.draw()
    love.graphics.clear(colors.background)

    -- Draw the main board and all sub-boards
    for i = 1, 3 do
        for j = 1, 3 do
            local offsetX = (j - 1) * cellSize * 3
            local offsetY = (i - 1) * cellSize * 3
            drawBoard(mainBoard[i][j], offsetX, offsetY)

            -- Highlight sub-boards that have been won
            if mainBoardStatus[i][j] == "D" then
                love.graphics.setColor(1, 1, 0)  -- Light green overlay for won boards
                love.graphics.rectangle("fill", offsetX, offsetY, cellSize * 3, cellSize * 3)
                love.graphics.setColor(colors.lines)
            end
            if mainBoardStatus[i][j] == "X" then
                love.graphics.setColor(1, 0, 0)  -- Light green overlay for won boards
                love.graphics.rectangle("fill", offsetX, offsetY, cellSize * 3, cellSize * 3)
                love.graphics.setColor(colors.lines)
            end
            if mainBoardStatus[i][j] == "O" then
                love.graphics.setColor(0, 0, 1)  -- Light green overlay for won boards
                love.graphics.rectangle("fill", offsetX, offsetY, cellSize * 3, cellSize * 3)
                love.graphics.setColor(colors.lines)
            end
        end
    end

    -- Display game status
    love.graphics.setColor(1, 1, 1)
    if gameWon then
        local tmp = " "
        if currentPlayer == "X" then
            tmp = "O"
        end
        if currentPlayer == "O" then
            tmp = "X"
        end
        
        love.graphics.print("Player " .. tmp .. " wins the game!", 10, windowHeight - 30)
    else
        love.graphics.print("Current Player: " .. currentPlayer, 10, windowHeight - 30)
    end


end



