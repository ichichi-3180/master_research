require 'parallel'

def sleepy(duration = 5.0)
  sleep duration
end

puts "Start: thread"

#-- スレッド --
#-- 約5秒 --
# Parallel.each(1..30, in_threads: 30) do
#   sleepy
# end
#----------------

#-- 約8秒で終了する --
Parallel.each(1..4000, in_threads: 4000) do
    sleepy
end
#-------------------

#-- can't create Thread: Resource temporarily unavailable (ThreadError) --
# Parallel.each(1..5000, in_threads: 5000) do
#     sleepy
# end
#-------------------


#-- プロセス --
#--inprocessで実行すれば想定通りの時間で済む(100くらいまでだったらこれで上手くいく, 500超えたあたりから時間が大分伸びる。1万とかだと無理) --
# Parallel.each(1..100, in_processes: 100) do
#     sleepy
# end
#----------------  

puts "End"