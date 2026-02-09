export type Post = { id: string; author: string; body: string; timestamp: number }
const KEY = 'everland_msg_board'

export function loadPosts(): Post[] {
  try { const raw = localStorage.getItem(KEY); if (!raw) return []; return JSON.parse(raw) as Post[] } catch(e) { return [] }
}

export function savePosts(posts: Post[]) { try { localStorage.setItem(KEY, JSON.stringify(posts)) } catch(e){} }

export function addPost(author: string, body: string) {
  const posts = loadPosts()
  posts.unshift({ id: String(Date.now()) + '-' + Math.floor(Math.random()*1000), author, body, timestamp: Date.now() })
  savePosts(posts.slice(0, 100))
}

export function clearPosts() { savePosts([]) }
