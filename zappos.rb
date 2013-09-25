#!/usr/bin/env ruby

require "net/https"
require "json"
require "uri"

# Pass in N and X as arguments from the terminal
n = ARGV[0]
x = ARGV[1]

$prices = Array.new
$names = Array.new

def get_product_list

	uri = URI.parse("http://api.zappos.com/Search/term/~1?limit=20&key=52ddafbe3ee659bad97fcce7c53592916a6bfd73")
	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Get.new(uri.request_uri)
	response = http.request(request)

	hash = JSON.parse response.body
	hash["results"].each do |result|
		# puts result["styleId"]
		$prices.push(result["price"].delete('$').to_f)
		$names.push(result["productName"])
	end
end

# prices = [100,212,312,4323,532,633,745,8546,9343,-4,-3,-1];
subSet = Array.new(n.to_i)
subSetName = Array.new(n.to_i)

$finalSubset = Array.new(n.to_i)
$finalNameSubset = Array.new(n.to_i)

$currentBestSum = 0

def findAllCombination(prices, subSet, setIndex, subSetIndex, sum, names, subSetName)
	if subSet.length == subSetIndex
		checkSum(subSet, sum, subSetName);
	else
		currIndex = setIndex
		while currIndex < prices.length
			subSet[subSetIndex] = prices[currIndex]
			subSetName[subSetIndex] = names[currIndex]
			findAllCombination(prices, subSet, currIndex+1, subSetIndex+1, sum, names, subSetName)
			currIndex += 1
		end
	end
end

def checkSum(subSet, sum, subSetName)
	currSum = 0
	subSet.each do |value|
			currSum += value;
	end

	if $finalSubset.to_a.empty?
		$finalSubset = subSet.dup
		$finalNameSubset = subSetName.dup
		$currentBestSum = currSum
	else
		if ($currentBestSum - sum).abs > (currSum - sum).abs
			$finalSubset = subSet.dup
			$finalNameSubset = subSetName.dup
			$currentBestSum = currSum
		end
	end
end

get_product_list
findAllCombination($prices, subSet, 0, 0, x.to_i, $names, subSetName)


puts "Product Recommendations for #{n} products with total value around #{x}"
index = 0
totalValue = 0
while index < $finalSubset.length
	puts "#{$finalNameSubset[index]} --> #{$finalSubset[index]}"
	totalValue += $finalSubset[index]
	index += 1
end

puts "Total Price #{totalValue}"