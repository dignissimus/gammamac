include karax / prelude
import std/parseutils
import std/math
import std/strutils
import std/strformat
import std/random

randomize()

type Operation = enum
  addition,
  subtraction,
  multiplication,
  division,

type Colour = enum
  blue,
  red,

type Direction = enum
  forward,
  backward

const directions = @[forward, backward]

proc class(colour: Colour): string =
  case colour
    of blue: "blue"
    of red: "red"

proc name(operation: Operation): string =
  case operation
    of addition: "addition"
    of subtraction: "subtraction"
    of multiplication: "multiplication"
    of division: "division"

proc symbol(operation: Operation): string =
  case operation
    of addition: "+"
    of subtraction: "-"
    of multiplication: "×"
    of division: "÷"

proc title(operation: Operation): string = operation.name.capitalizeAscii

proc perform(operation: Operation, left: Natural, right: Natural): Natural =
  case operation
    of addition:
      left + right
    of multiplication:
      left * right
    of subtraction:
      left - right
    of division:
      cast[int](floor(left / right))

type OperationGroup = object
  forward: Operation
  backward: Operation
  colour: Colour

const operationGroups = @[
    OperationGroup(forward: addition, backward: subtraction, colour: blue),
    OperationGroup(forward: multiplication, backward: division, colour: red),
]

type Question = object
  left: Natural
  right: Natural
  group: OperationGroup
  direction: Direction

proc result(question: Question): Natural =
  question.group.forward.perform(question.left, question.right)

proc verify(question: Question, answer: Natural): bool =
  case question.direction
    of forward:
      answer == question.result
    of backward:
      answer == question.right


proc randomQuestion: Question = Question(
    left: rand(2..12),
    right: rand(2..100),
    group: operationGroups.sample,
    direction: directions.sample,
)

proc render(group: OperationGroup): Vnode =
  buildhtml(tdiv(class = fmt"operation-group {group.colour.class}")):
    tdiv(class = "operation"):
      text fmt"{group.forward.title} and {group.backward.title}"
    tdiv(class = "range"):
      tdiv:
        input(value = "2", inputmode = "numeric")
        text "to"
        input(value = "100", inputmode = "numeric")

      tdiv: text group.forward.symbol

      tdiv:
        input(value = "2", inputmode = "numeric")
        text "to"
        input(value = "100", inputmode = "numeric")


type GamePhase = enum
  setup, play

var phase = setup
var score = 0

proc setupGame(): Vnode =
  buildHtml(tdiv):
    for group in operationGroups:
      group.render
    tdiv(class = "button-container"):
      button:
        text "Start game"
        proc onclick =
          phase = play
          score = 0

var question = randomQuestion()
proc playGame(): VNode =
  buildHtml(tdiv):
    tdiv(class = "question"):
      case question.direction
        of forward:
          text fmt"{question.left} {question.group.forward.symbol} {question.right}"
        of backward:
          text fmt"{question.result} {question.group.backward.symbol} {question.left}"

    tdiv(class = "answer"):
      tdiv: h2: text "Answer"
      input(inputmode = "numeric"):
        proc onkeyup(event: Event, target: Vnode) =
          var result = 0
          discard parseSaturatedNatural($target.value, result)
          if question.verify(result):
            question = randomQuestion()
            target.setInputText("")

proc website(): VNode =
  buildHtml(tdiv):
    h1:
      text "Gammamac"
    case phase
      of setup: setupGame()
      of play: playGame()
    tdiv(class = "credits"):
      text "Made by "
      a(href = "https://ezeh.uk"):
        text "Sam Ezeh"
setRenderer website
