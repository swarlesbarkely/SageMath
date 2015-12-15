##################################################
# Converts transfer function from S Plane to Z Plane
# Gs -- Transfer function in S Plane
# T -- Sampling time
# MatchedFrequency -- Frequency to match gain at
##################################################

def S2Z (Gs, T, MatchedFrequency = 0):

	j = CC.0
	
	SPoles = [i[0] for i in Gs.denominator().roots()]
	ZPoles = [exp (i * T) for i in SPoles]
	
	Gz = 1 / prod ([z - i for i in ZPoles])
	
	# Match the phase
	try:
		# Find phase of G(s)
		Temp = Gs.subs (s == j)
		GsPhase = CDF (Temp.real(), Temp.imag()).argument()
		
		# Want to make sure phase is positive
		if GsPhase < 0:
			GsPhase = GsPhase + 2*pi
		
		# Find phase of G(z)
		Temp = Gz.subs (z == exp (j * T))
		GzPhase = CDF (Temp.real(), Temp.imag()).argument()
		
		# Each extra z on top adds to the phase --> find the difference
		Temp = exp (j * T)
		Temp = CDF (Temp.real(), Temp.imag()).argument()
		ZDegree = ((GsPhase - GzPhase) / Temp).round()
		
	except ZeroDivisionError:	
		# Try a different s
		# Find phase of G(s)
		try:
			
			Temp = Gs.subs (s == pi * j)
			GsPhase = CDF (Temp.real(), Temp.imag()).argument()
		
			# Find phase of G(z)
			Temp = Gz.subs (z == exp (pi * j * T))
			GzPhase = CDF (Temp.real(), Temp.imag()).argument()
		
			# Each extra z on top adds to the phase --> find the difference
			Temp = exp (pi * j * T)
			Temp = CDF (Temp.real(), Temp.imag()).argument()
			ZDegree = ((GsPhase - GzPhase) / Temp).round()
		
		except ZeroDivisionError:
			print "Error matching phase!"
			return
	
	# Update G(z)	
	Gz = Gz * z ^ (ZDegree)
	
	# Match the gain
	try:
		Temp = Gs.subs (s == j * MatchedFrequency).abs()
		K = Temp / (Gz.subs (z == exp (j * MatchedFrequency)).abs())
		
	except ZeroDivisionError:
		print "Error matching gain!"
		return
		
	return K * Gz
