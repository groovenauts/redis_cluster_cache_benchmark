
$chars ||= ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a

i = rand(10000)
key = i.to_s

unless value = $client.get(key)
  value = (1..i).map{|_| $chars.sample}.join
  $client.set(key, value)
end
