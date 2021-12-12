const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    "./_site/**/*.html"
  ],
  theme: {
    colors: {
      ...colors,
      primary: '#0369a1',
      'light-primary': '#e0f2fe',
      secondary: '#eab308',
    }
  },
  plugins: [
    require('@tailwindcss/typography')
  ],
}
