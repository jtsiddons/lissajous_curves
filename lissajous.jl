using CairoMakie, Colors, Statistics

# I want a full circle
θs = 0.0:0.005:2.0;
lθ = length(θs);

n = 5;		# Number of circles
r = 0.3;	# Radius

# Create empty array to save points for lines drawn out. 
curves = fill((0.,0.), (n, n, length(θs)));

# Points on each circle. Left and bottom circles resp
lcircs(θ) = [(r*cos(i*θ*pi), i + r*sin(i*θ*pi)) for i = 1:n];
bcircs(θ) = [(i + r*cos(i*θ*pi), r*sin(i*θ*pi)) for i = 1:n];

ls = [lcircs(θ) for θ in θs];
bs = [bcircs(θ) for θ in θs];

# Get the curves
for j = 1:n, k = 1:n, i in 1:length(θs)
	pt = (bs[i][j][1], ls[i][k][2])
	curves[j,k,i] = pt
end

# Colors for the plots
rds = range(RGB(1,0.8,0.8), RGB(1,0,0), n);
bls = range(RGB(0.8,0.8,1), RGB(0,0,1), n);

bg = colorant"#282828";
fg = colorant"#ebd2bb";
lg = colorant"#a89984";

function coladd(r::RGB{Float64}, b::RGB{Float64})
	nr = mean([r.r, b.r])
	ng = mean([r.g, b.g])
	nb = mean([r.b, b.b])
	return RGB(nr, ng, nb)
end

sharecols = [coladd(r, b) for r in rds, b in bls]

# Loop 
for i in 1:10:lθ
	fi = "./frames/frame_" * lpad(string(i),4,"0") * ".png";

	F = Figure(resolution = (500, 500), figure_padding=0);
	A = Axis(
		F[1,1], 
		aspect=1,
		backgroundcolor=bg
	);
	hidedecorations!(A)
	hidespines!(A)

	# Add in circles & lines from current point
	for j = 1:n
		poly!(A, Circle(Point2f(0,j), r), color=rds[j], strokewidth=2, strokecolor=fg)
		poly!(A, Circle(Point2f(j,0), r), color=bls[j], strokewidth=2, strokecolor=fg)
		# hlines!(A, [ls[j][2]], linewidth=1, color=lg, linestyle = :dash)
		# vlines!(A, [bs[j][1]], linewidth=1, color=lg, linestyle = :dash)
		lines!(A, [(ls[i][j][1],ls[i][j][2]), (bs[i][n][1], ls[i][j][2])], color=lg, linewidth=0.75, linestyle=:dash)
		lines!(A, [(bs[i][j][1],bs[i][j][2]), (bs[i][j][1], ls[i][n][2])], color=lg, linewidth=0.75, linestyle=:dash)
		
		# Loop through each pair of lines to add to the drawings
		for k in 1:n
			lines!(A, curves[j,k,1:i], color=sharecols[k,j], linewidth=2)
			scatter!(A, (bs[i][k][1], ls[i][j][2]), markersize=10, color=fg)
		end
	end

	# Add in current point
	scatter!(A, ls[i], color=fg, markersize=10)
	scatter!(A, bs[i], color=fg, markersize=10)


	# Save the frame
	save(fi, F, px_per_unit=0.75)
end

# 2nd Loop - overwrite lines with background
# for i in 1:10:lθ
#     
#     i2 = i+lθ
# 	fi = "./frames/frame_" * lpad(string(i2),4,"0") * ".png";
# 
# 	F = Figure(resolution = (500, 500), figure_padding=0);
# 	A = Axis(
# 		F[1,1], 
# 		aspect=1,
# 		backgroundcolor=bg
# 	);
# 	hidedecorations!(A)
# 	hidespines!(A)
# 
# 	# Add in circles & lines from current point
# 	for j = 1:n
# 		poly!(A, Circle(Point2f(0,j), r), color=rds[j], strokewidth=2, strokecolor=fg)
# 		poly!(A, Circle(Point2f(j,0), r), color=bls[j], strokewidth=2, strokecolor=fg)
# 		# hlines!(A, [ls[j][2]], linewidth=1, color=lg, linestyle = :dash)
# 		# vlines!(A, [bs[j][1]], linewidth=1, color=lg, linestyle = :dash)
# 		lines!(A, [(ls[i][j][1],ls[i][j][2]), (bs[i][n][1], ls[i][j][2])], color=lg, linewidth=0.75, linestyle=:dash)
# 		lines!(A, [(bs[i][j][1],bs[i][j][2]), (bs[i][j][1], ls[i][n][2])], color=lg, linewidth=0.75, linestyle=:dash)
# 		
# 		# Loop through each pair of lines to add to the drawings
# 		for k in 1:n
#             lines!(A, curves[j,k,i+1:lθ],color=sharecols[k,j], linewidth=2)
# 			scatter!(A, (bs[i][k][1], ls[i][j][2]), markersize=10, color=fg)
# 		end
# 	end
# 
# 	# Add in current point
# 	scatter!(A, ls[i], color=fg, markersize=10)
# 	scatter!(A, bs[i], color=fg, markersize=10)
# 
# 
# 	# Save the frame
# 	save(fi, F, px_per_unit=0.75)
# end

# Generate animation (in built gif creation doesn't work for me 😿
run(`convert -delay 10 -loop 0 'frames/*' lissajous.gif`)
