function fish_greeting
    if command -q fortune && command -q cowsay
        fortune -s | cowsay -r
    else
        echo ' __________________________________________________
< Welcome to Fish! The friendly interactive shell. >
 --------------------------------------------------
  \
   \
         /\
         \.\_
\`-\..:-`    `-.
 )  _       ( o :
/.-` ;--,....-"`
          `\''
    end
end
