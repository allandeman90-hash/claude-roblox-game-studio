---
title: Object Oriented Programming with Luau in 2023
type: raw-source
source_url: https://devforum.roblox.com/t/object-oriented-programming-with-luau-in-2023/2135043
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: laindecat (Lain)
post_date: 2023-01-11
tags: [oop, luau, type-checking, metatables, classes]
---

# Object Oriented Programming with Luau in 2023

**Author:** laindecat (Lain)
**Posted:** January 11, 2023

## Overview

A class implementation method using Luau's type-checking system. The approach separates concerns into three distinct type definitions: `Impl` (class structure and methods), `Proto` (object properties), and an exported `Account` type wrapping both within a metatable.

## Core Pattern

```lua
--!strict

type Impl = {
	__index: Impl,
	new: (name: string, balance: number) -> Account,
	deposit: (self: Account, credit: number) -> (),
	withdraw: (self: Account, debit: number) -> (),
}

type Proto = {
	name: string,
	balance: number
}

local Account: Impl = {} :: Impl
Account.__index = Account

export type Account = typeof(setmetatable({} :: Proto, {} :: Impl))

function Account.new(name: string, balance: number)
	local self = setmetatable({} :: Proto, Account)
	self.name = name
	self.balance = balance
	return self
end

function Account:withdraw(debit): ()
	self.balance -= debit
end

function Account:deposit(credit): ()
	self.balance += credit
end

return Account
```

**Key Insight:** "The `()` is kind of an equivalent to `void`" indicating no return value from methods.

## Alternative Simplified Method (Swetch29, July 2023)

Uses automatic type inference through `typeof()` rather than manual type definitions:

```lua
--!strict
local Account = {
    name = "Account",
    balance = 0
}

Account.__index = Account
export type Account = typeof(Account)

function Account.new(name: string, balance: number): Account
    local self = setmetatable({}, Account)
    self.name = name
    self.balance = balance
    return self
end

function Account:withdraw(debit: number): nil
    self.balance -= debit
end

function Account:deposit(credit: number): nil
    self.balance += credit
end

return Account
```

## Refined Hybrid Version (laindecat, July 2023)

Combines explicit self parameters with property inference:

```lua
--!strict

local Account = {}
Account.__index = Account

type Properties = {
	name: string,
	balance: number
}

function Account.new(name: string, balance: number)
	local properties: Properties = {
		name = name,
		balance = balance
	}
	return setmetatable(properties, Account)
end

export type Account = typeof(Account.new(...))

function Account.withdraw(self: Account, debit: number)
	self.balance -= debit
end

function Account.deposit(self: Account, credit: number)
	self.balance += credit
end

return Account
```

## Philosophical Discussion

**Terminology:** The term "Impl" likely derives from Rust's implementation keyword.

**Paradigm Debate:** A contributor argues that "Lua/Luau is not an object-oriented language, but prototype-based" and advocates for functional approaches using plain functions rather than metatables.

**Functional Alternative Example:**
```lua
type Account = {
	Name: string,
	Balance: number
}

local function DepositAccount(self: Account, Amount: number)
	self.Balance += Amount
end

local function WithdrawAccount(self: Account, Amount: number)
	self.Balance -= Amount
end
```

## Key Takeaway

The original post addresses a genuine friction point: "since types came out, it became difficult to get type checking right without complex workarounds." The various solutions reflect ongoing community discussion about balancing Lua's prototype-based nature with modern type-checking expectations.

## Source

Original URL: https://devforum.roblox.com/t/object-oriented-programming-with-luau-in-2023/2135043
Captured: 2026-04-16
