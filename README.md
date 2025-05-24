# FlipTrick
### A Motion-Based iOS Game: Flip, Spin, and Score!

<div align="center" style="display: flex; gap: 12px; flex-wrap: wrap;">
  <img src="https://i.imgur.com/CCOPzE4.gif" alt="FlipTrick Gameplay 1" width="250"/>
  <img src="https://i.imgur.com/QE7cnN1.gif" alt="FlipTrick Gameplay 2" width="250"/>
  <img src="https://i.imgur.com/TfWtg7M.gif" alt="FlipTrick Gameplay 3" width="250"/>
</div>

### Built With
![Swift Badge](https://img.shields.io/badge/Swift-FA7343?logo=swift&logoColor=fff&style=for-the-badge)
![UIKit Badge](https://img.shields.io/badge/UIKit-000?logo=apple&logoColor=fff&style=for-the-badge)
![CoreMotion Badge](https://img.shields.io/badge/CoreMotion-007AFF?logo=apple&logoColor=fff&style=for-the-badge)
![Xcode Badge](https://img.shields.io/badge/Xcode-1575F9?logo=xcode&logoColor=fff&style=for-the-badge)

## Features
### Motion-Based Gameplay
- **Flip, spin, and rotate** your phone to perform tricks.
- **Real-time scoring** for each detected move.
- **Combo/multiplier system** for chaining unique tricks.

### Game Modes
- **Endless Mode:** Play as long as you can keep moving.
- **Timed Mode:** Race against the clock for the highest score.

### Move & Score History
- **Move history:** See your recent tricks in a table view.
- **Score history:** Track your previous high scores and sessions.

### User Experience
- **Score decay:** Pausing too long causes your score to drop.
- **Tutorial:** Learn how to play with an in-app guide.
- **Tab bar navigation:** Easily switch between gameplay, scores, and about/tutorial.

## Roadmap
- [x] Gyroscope-based trick detection
- [x] Real-time scoring and combos
- [x] Move and score history
- [x] Endless & timed game modes
- [x] Score decay after inactivity
- [x] Tab bar navigation
- [x] Tutorial/onboarding
- [ ] Leaderboards (global/friends)
- [ ] Friend challenges
- [ ] Achievements
- [ ] UI improvements
- [ ] Refactor game logic into separate class
- [ ] Sound effects
- [ ] Haptic feedback

## How It Works
1. **Start a Game:** Choose endless or timed mode.
2. **Perform Tricks:** Flip, spin, or rotate your phone—each unique move is detected and scored.
3. **Build Combos:** Chain different moves together for score multipliers.
4. **Stay Active:** If you pause, your score starts to decay!
5. **View History:** Check your previous scores and move history.
6. **Compete:** Try to beat your own high score (and, in the future, your friends’ scores).

## Inspiration
Inspired by fidgeting with my phone while walking around campus, I wanted to create a game that turns those movements into a fun, competitive experience. FlipTrick is for anyone who enjoys quick, active games—especially students, fidgeters, or anyone looking for a unique way to compete with friends.

Also was done as part of CodePath's Intro to iOS Course as the final project.

## Future Plans
- **Leaderboards:** Compete globally or with friends.
- **Friend Challenges:** Challenge friends to beat your score.
- **Achievements:** Unlock badges for special moves and milestones.
- **Customization:** Themes, colors, and more.
- **Enhanced Feedback:** Sound effects and haptic feedback for combos.
