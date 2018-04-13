local io = io
local print = print
local os = os

local function BasicTests()
	local UTest = require 'tests\\framework\\u-test'

	local Lib = require 'LibDeflate'

	local function CheckFile(inputFileName)
		local inputFile = io.open(inputFileName, "rb")
		local inputFileContent = inputFile:read("*all")
		local inputFileLen = inputFileContent:len()
		print(("%s: %d bytes"):format(inputFileName, inputFileLen))
		inputFile:close()

		local startTime = os.clock()
		--os.execute("rm -f profileresult.txt")
		--profiler.start("profileresult.txt")
		local compressed = Lib:Compress(inputFileContent)
		local elapsed = os.clock()-startTime
		print(("compressed size: %d, time: %.4f"):format(compressed:len(), elapsed))
		--profiler.stop()

		local outputFile = io.open(inputFileName..".deflate", "wb")
		outputFile:write(compressed)
		outputFile:close()

		os.execute("rm -f "..inputFileName..".decompressed")
		
		-- puff is a small deflate decompression program in the source code of zlib
		-- https://github.com/madler/zlib/tree/master/contrib/puff
		-- How I build it under Windows:
		-- 1. Install Visual Studio
		-- 2. Edit puff.c: in line 23: #if defined(MSDOS) || defined(OS2) || defined(WIN32) || defined(__CYGWIN__)
		--    Add "|| defined(_WIN32)" at the end
		-- 3. Search "x64 native build tools" in the open menu and open it. You'll see a command line prompt
		-- 4. switch the current folder to the source of puff, 
		--    Enter the command: "cl puff.c pufftest.c", the executable "puff.c" should be generated.
		-- 5. Put "puff.exe" under the PATH of your computer.
		os.execute("puff -w "..inputFileName..".deflate > "..inputFileName..".decompressed")

		local testFile = io.open(inputFileName..".decompressed", "rb")
		local testFileContent = testFile:read("*all")
		testFile:close()

		UTest.equal(inputFileContent, testFileContent, inputFileName)
	end

	---- Test begins
	function UTest.FirstTest()
		CheckFile("tests\\data\\smalltest.txt")
	end
	
	function UTest.BigTest()
	  local files = {"bib", "pic"} -- "book1", "book2", "geo", "news", "obj1", "obj2", "paper1", "paper2", "pic", "progc", "progl", "progp", "trans"
	  for _, file in ipairs(files) do
	   CheckFile("tests\\data\\calgary\\"..file)
	  end
	end
end

BasicTests()
