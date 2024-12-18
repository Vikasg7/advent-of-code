#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local register, program = { }, { }

  register.A = tonumber(string.match(io.read("*l"), "Register A%: (%d+)"))
  register.B = tonumber(string.match(io.read("*l"), "Register B%: (%d+)"))
  register.C = tonumber(string.match(io.read("*l"), "Register C%: (%d+)"))

  local _ = io.read("*l")

  for inst in string.gmatch(io.read("*l") .. ",", "(%d),") do
    table.insert(program, tonumber(inst))
  end

  return register, program
end

function ResolveComboOperand(register, operand)
  if operand < 4 then
    return operand
  end
  if operand == 4 then
    return register.A
  end
  if operand == 5 then
    return register.B
  end
  if operand == 6 then
    return register.C
  end
  error(string.format("Unreachable: Invalid operand: %d", operand))
end

function RunProgram(register, program)
  local ip, output = 1, { }

  local opcode, operand
  while ip <= #program do
    opcode = program[ip] 
    operand = program[ip+1]

    if opcode == 0 then
      register.A = math.floor(register.A / (2 ^ (ResolveComboOperand(register, operand))))
    elseif opcode == 1 then
      register.B = register.B ~ operand
    elseif opcode == 2 then
      register.B = ResolveComboOperand(register, operand) % 8
    elseif opcode == 3 then
      if register.A ~= 0 then
        ip = operand + 1
        goto next_inst
      end
    elseif opcode == 4 then
      register.B = register.B ~ register.C
    elseif opcode == 5 then
      table.insert(output, ResolveComboOperand(register, operand) % 8)
    elseif opcode == 6 then
      register.B = math.floor(register.A / (2 ^ (ResolveComboOperand(register, operand))))
    elseif opcode == 7 then
      register.C = math.floor(register.A / (2 ^ (ResolveComboOperand(register, operand))))
    end

    ip = ip + 2
    ::next_inst::
  end

  return table.concat(output, ",")
end

function FindRegisterA(register, program, pLen, initial_a)
  if pLen == 0 then
    register.A = initial_a
    if RunProgram(register, program) ~= table.concat(program, ",") then
      return false
    end
    return initial_a
  end

  for bit = 0, 7 do
    register.A = (initial_a << 3) | bit
    register.B = 0
    register.C = 0

    local ip = 1
    local output = nil
    local advCnt = 0

    while ip <= #program do
      local opcode = program[ip]
      local operand = program[ip+1]

      if opcode == 0 then
        advCnt = advCnt + 1
        assert(operand == 3, "progam can only contain adv instruction with operand = 3")
        assert(advCnt == 1, "progran can contain only one adv instruction")
      elseif opcode == 1 then
        register.B = register.B ~ operand
      elseif opcode == 2 then
        register.B = ResolveComboOperand(register, operand) % 8
      elseif opcode == 3 then
        -- ignores the jump statment
      elseif opcode == 4 then
        register.B = register.B ~ register.C
      elseif opcode == 5 then
        output = ResolveComboOperand(register, operand) % 8
      elseif opcode == 6 then
        register.B = math.floor(register.A / (2 ^ (ResolveComboOperand(register, operand))))
      elseif opcode == 7 then
        register.C = math.floor(register.A / (2 ^ (ResolveComboOperand(register, operand))))
      end

      ip = ip + 2
    end

    if output == program[pLen] then
      -- print(register.A, output, program[pLen], pLen)
      -- bracktracking if can't find next valid sub_a
      local sub_a = FindRegisterA(register, program, pLen-1, register.A)
      if not sub_a then
        goto next_bit
      end
      return sub_a
    end

    ::next_bit::
  end

  return false
end

function Main()
  local register, program = ParseInput()
  local register_copy = table.deep_copy(register)
  print("Part1:", RunProgram(register, program))
  print("Part2:", FindRegisterA(register_copy, program, #program, 0))
end

-- time cat 2024/input/17.txt | ./2024/17.lua
-- Part1:  1,5,7,4,1,6,0,3,0
-- Part2:  108107574778365
Main()