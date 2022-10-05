printf("Refinerty input:\n")
ticks_per_second = 20
mb_per_tick = 8
mb_per_second = mb_per_tick * ticks_per_second
printf("\n")

printf("Fermenter:\n")
output_mb_per_second = 80
mb_per_melon = 20
mb_per_potato = 80
melons_per_second = output_mb_per_second / mb_per_melon
potatos_per_second = output_mb_per_second / mb_per_potato
printf("\n")

printf("Squeezer:\n")
output_mb_per_second = 160
printf("\n")

printf("Cloches:\n")
sample_duration = 18*60 + 40
sample_count = 38
sample_per_second = sample_count / sample_duration
seconds_per_sample = 1 / sample_per_second
potatoes_per_minute = 2
potatoes_per_second = potatoes_per_minute / 60
target_potatoes_per_second = 2
num_cloches = target_potatoes_per_second / potatoes_per_second
printf("\n")
