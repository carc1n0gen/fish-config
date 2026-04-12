function grimslurp
   if command -q grim && command -q slurp && command -q wl-copy
       set -l IMG ~/Pictures/Screenshots/(date +%Y-%m-%d_%H:%M:%S).png
       grim -g (slurp) $IMG && wl-copy < $IMG
   else
       echo "grim, slurp, and wl-copy are required for grimslurp to work."
   end
end
