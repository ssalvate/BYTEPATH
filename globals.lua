default_color = {222, 222, 222}
background_color = {16, 16, 16}
ammo_color = {123, 200, 164}
boost_color = {76, 195, 217}
hp_color = {241, 103, 69}
skill_point_color = {255, 198, 93}
default_colors = {default_color, hp_color, ammo_color, boost_color, skill_point_color}
negative_colors = {
        {255-default_color[1], 255-default_color[2], 255-default_color[3]}, 
        {255-hp_color[1], 255-hp_color[2], 255-hp_color[3]}, 
        {255-ammo_color[1], 255-ammo_color[2], 255-ammo_color[3]}, 
        {255-boost_color[1], 255-boost_color[2], 255-boost_color[3]}, 
        {255-skill_point_color[1], 255-skill_point_color[2], 255-skill_point_color[3]}
    }
all_colors = fn.append(default_colors, negative_colors)
--  Attacks  --
attacks = {
    ['Neutral'] = {cooldown = 0.24, ammo = 0, abbreviation = 'N', color = default_color},
    ['Double'] = {cooldown = 0.32, ammo = 2, abbreviation = '2', color = ammo_color},
    ['Triple'] = {cooldown = 0.32, ammo = 3, abbreviation = '3', color = boost_color},
    ['Rapid'] = {cooldown = 0.12, ammo = 1, abbreviation = 'R', color = default_color},
    ['Spread'] = {cooldown = 0.16, ammo = 1, abbreviation = 'RS', color = default_color},
    ['Back'] = {cooldown = 0.32, ammo = 2, abbreviation = 'Ba', color = skill_point_color},
    ['Side'] = {cooldown = 0.32, ammo = 2, abbreviation = 'Si', color = boost_color}
}