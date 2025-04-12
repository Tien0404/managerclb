import { defineStore } from 'pinia';
import * as eventService from '../services/eventService';

export const useEventStore = defineStore('eventStore', {
  state: () => ({
    events: [],
    loading: false,
    error: null,
  }),
  actions: {
    async fetchEvents() {
      this.loading = true;
      this.error = null;
      try {
        const events = await eventService.getEvents();
        this.events = events;
        return events;
      } catch (err) {
        this.error = err.message || 'Error fetching events';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async fetchEvent(id) {
      this.loading = true;
      this.error = null;
      try {
        return await eventService.getEvent(id);
      } catch (err) {
        this.error = err.message || 'Error fetching the event';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async createEvent(eventData) {
      this.loading = true;
      this.error = null;
      try {
        const newEvent = await eventService.createEvent(eventData);
        this.events.push(newEvent);
      } catch (err) {
        this.error = err.message || 'Error creating the event';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async updateEvent(id, eventData) {
      this.loading = true;
      this.error = null;
      try {
        const updatedEvent = await eventService.updateEvent(id, eventData);
        const index = this.events.findIndex(event => event.id === id);
        if (index !== -1) {
          this.events[index] = updatedEvent;
        }
      } catch (err) {
        this.error = err.message || 'Error updating the event';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async deleteEvent(id) {
      this.loading = true;
      this.error = null;
      try {
        await eventService.deleteEvent(id);
        this.events = this.events.filter(event => event.id !== id);
      } catch (err) {
        this.error = err.message || 'Error deleting the event';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
  },
});