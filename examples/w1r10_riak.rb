
$chars ||= ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a

i = rand(10000)
key = i.to_s

obj = $client.get_object("rccb_bench", key) rescue nil
unless obj
  $client.store "rccb_bench", key, (1..i).map{|_| $chars.sample}.join
end
