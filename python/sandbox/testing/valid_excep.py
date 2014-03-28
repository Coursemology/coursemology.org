def exception_trigger(x):
	print(x)
	if x == 5:
		x = 1 / 0
	return 0


print(exception_trigger(1) == 0)
print(exception_trigger(2) == 0)
print(exception_trigger(3) == 0)
print(exception_trigger(4) == 0)
print(exception_trigger(5) == 0)
print(exception_trigger(4) == 0)