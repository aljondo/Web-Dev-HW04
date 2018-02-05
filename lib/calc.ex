defmodule Calc do
  def main do
    equation = IO.gets ""
    split = String.split(equation)
    Calc.eval(split)
    Calc.main
  end

  def eval(equation) when length(equation) === 1 do
    Enum.at(equation, 0)
  end

  def eval(equation) do
    if Enum.any?(equation, fn(x) -> String.contains?(x, "(") end) do
      opens = Calc.find_indexes(equation, fn(x) -> String.contains?(x, "(") end)
      openP = Enum.at(opens, length(opens) - 1)
      closeP = Enum.find_index(equation, fn(x) -> String.contains?(x, ")") end)
      openEl = Enum.at(equation, openP) |> String.slice(1..-1)
      closeEl = Enum.at(equation, closeP) |> String.slice(0..-2)
      parenResult = List.replace_at(equation, openP, openEl)
      |> List.replace_at(closeP, closeEl)
      |> Enum.slice(openP, closeP - openP + 2)
      |> eval
      List.replace_at(equation, openP, parenResult)
      |> List.delete_at(openP + 1)
      |> List.delete_at(openP + 1)
      |> eval
    else
      if Enum.member?(equation, "*") or Enum.member?(equation, "/") do
        opIndex = Enum.min([Enum.find_index(equation, fn(x) -> x == "/" end),
          Enum.find_index(equation, fn(x) -> x == "*" end)])
      else
        opIndex = Enum.min([Enum.find_index(equation, fn(x) -> x == "+" end),
          Enum.find_index(equation, fn(x) -> x == "-" end)])
      end
      expResult = Integer.to_string(
        Calc.evalShortExpr(
          Enum.at(equation, opIndex - 1),
          Enum.at(equation, opIndex + 1),
          Enum.at(equation, opIndex)
        )
      )
      List.replace_at(equation, opIndex, expResult)
      |> List.delete_at(opIndex + 1)
      |> List.delete_at(opIndex - 1)
      |> Calc.eval
    end
  end

  def evalShortExpr(x, y, op) do
    iX = String.to_integer(x)
    iY = String.to_integer(y)
    case op do
      "+" ->
        iX + iY
      "-" ->
        iX - iY
      "*" ->
        iX * iY
      "/" ->
        Integer.floor_div(iX, iY)
    end
  end

  #attributed from https://stackoverflow.com/questions/18551814/find-indexes-from-list-in-elixir
  def find_indexes(collection, function) do 
    do_find_indexes(collection, function, 0, [])
  end

  def do_find_indexes([], _function, _counter, acc) do
    Enum.reverse(acc)
  end

  def do_find_indexes([h|t], function, counter, acc) do
    if function.(h) do
      do_find_indexes(t, function, counter + 1, [counter|acc])
    else
      do_find_indexes(t, function, counter + 1, acc)
    end
  end
 end