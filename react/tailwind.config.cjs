module.exports = {
  content: [
    './index.html',
    './src/**/*.{ts,tsx,js,jsx}',
    '../bbs/**/*.{md,inc,asm,json}'
  ],
  theme: {
    extend: {
      colors: {
        everland: {
          900: '#0b1020',
          800: '#0f1a2b',
          700: '#162433'
        }
      }
    }
  },
  plugins: [require('@tailwindcss/typography')]
}
