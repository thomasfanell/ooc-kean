use ooc-base
use ooc-unit

TextBuilderTest: class extends Fixture {
	init: func {
		super("TextBuilder")
		this add("creating", func {
			tb := TextBuilder new()
			tb append(c"vid", 3)
			tb append(c"flow", 4)
			text := tb toText()
			expect(text count == 7)
			expect(text == "vidflow")
			tb = TextBuilder new(Text new("1,2,3").split(','))
			text = tb join(';')
			expect(text == "1;2;3")
			tb free()
			text free()
		})
		this add("append", func {
			tb := TextBuilder new()
			tb append(Text new(c"test", 4))
			tb append(c" test", 5)
			tb append(c" data", 5)
			expect(tb count == 3)
			expect(tb == "test test data")
		})
		this add("prepend", func {
			tb := TextBuilder new(c"World", 5)
			tb prepend(c"Hello ", 6)
			expect(tb count, is equal to(2))
			expect(tb  == "Hello World")
			tb prepend(c"String ", 7)
			expect(tb count, is equal to(3))
			expect(tb == "String Hello World")
			tb2 := TextBuilder new(c" in ooc", 7)
			tb2 prepend(tb)
			expect(tb2 count, is equal to(4))
			expect(tb2 == "String Hello World in ooc")
		})
		this add("copy", func {
			sb := TextBuilder new(c"Hello World", 11)
			sb2 := sb copy()
			expect(sb toText() == sb2 toText())
		})
		this add("== operator", func {
			sb := TextBuilder new(c"Hello", 5)
			sb2 := TextBuilder new(c"Hello", 5)
			sb3 := TextBuilder new(c"World", 5)
			expect(sb == sb2)
			expect(sb != sb3)
			expect(sb == "Hello")
			expect(sb != "World")
			expect("Hello" == sb)
			expect("World" != sb)
			expect(sb == sb toText())
			expect(sb toString() == sb toText())
		})
		this add("join", func {
			tb := TextBuilder new()
			tb append(c"1", 1)
			tb append(c"2", 1)
			tb append(c"3", 1)
			tb append(c"4", 1)
			text := tb join(',')
			expect(text == "1,2,3,4")
			text = tb join(Text new("--><--"))
			expect(text == "1--><--2--><--3--><--4")
			tb free()
		})
	}
}

TextBuilderTest new() run()