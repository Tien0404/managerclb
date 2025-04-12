import { defineStore } from 'pinia';
import DepartmentService from '../services/department';
const userData = JSON.parse(localStorage.getItem('user'));
const userId = userData?.id;

export const useDepartmentStore = defineStore('department', {
    state: () => ({
        departments: [],
        clubDepartments: [],
        selectedDepartment: null,
        currentDepartment: null,
        isLoading: false,
        loading: false,
        error: null,
        userRole: {
            owner_id: null,
            id: null,
            name: null,
            description: null,
            manage_clubs: 0,
            manage_events: 0,
            manage_members: 0,
            manage_blogs: 0,
            manage_feedback: 0
        }
    }),

    getters: {
        getDepartmentById: (state) => (id) => {
            return state.departments.find(dept => dept.id === id);
        },
        
        getClubDepartments: (state) => {
            return state.clubDepartments;
        },
        
        // Check if user is club owner
        isClubOwner: (state) => {
            return state.userRole.owner_id === userId;
        },
        
        // Check permissions for specific features
        canManageClubs: (state) => {
            return state.userRole.owner_id === userId || state.userRole.manage_clubs === 1;
        },
        
        canManageEvents: (state) => {
            return state.userRole.owner_id === userId || state.userRole.manage_events === 1;
        },
        
        canManageMembers: (state) => {
            return state.userRole.owner_id === userId || state.userRole.manage_members === 1;
        },
        
        canManageBlogs: (state) => {
            return state.userRole.owner_id === userId || state.userRole.manage_blogs === 1;
        },
        
        canManageFeedback: (state) => {
            return state.userRole.owner_id === userId || state.userRole.manage_feedback === 1;
        }
    },

    actions: {
        async fetchDepartments() {
            this.isLoading = true;
            this.error = null;
            
            try {
                const data = await DepartmentService.getAllDepartments();
                this.departments = data;
            } catch (error) {
                this.error = error.message;
                console.error('Error fetching departments:', error);
            } finally {
                this.isLoading = false;
            }
        },

        async fetchClubDepartments(clubId) {
            this.isLoading = true;
            this.error = null;
            
            try {
                const data = await DepartmentService.getAllDepartmentsClub(clubId);
                this.clubDepartments = data.departments || [];
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error fetching club departments:', error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async fetchDepartmentById(id) {
            this.isLoading = true;
            this.error = null;
            
            try {
                const data = await DepartmentService.getDepartmentById(id);
                this.selectedDepartment = data;
                this.currentDepartment = data;
                this.error = null;
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error fetching department:', error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async createDepartment(departmentData) {
            this.isLoading = true;
            this.error = null;
            
            try {
                const data = await DepartmentService.createDepartment(departmentData);
                this.departments.push(data);
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error creating department:', error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async updateDepartment(id, departmentData) {
            this.isLoading = true;
            this.error = null;
            
            try {
                const data = await DepartmentService.updateDepartment(id, departmentData);
                const index = this.departments.findIndex(dept => dept.id === id);
                if (index !== -1) {
                    this.departments[index] = data;
                }
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error updating department:', error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async deleteDepartment(id) {
            this.isLoading = true;
            this.error = null;
            
            try {
                await DepartmentService.deleteDepartment(id);
                this.departments = this.departments.filter(dept => dept.id !== id);
                this.clubDepartments = this.clubDepartments.filter(dept => dept.id !== id);
            } catch (error) {
                this.error = error.message;
                console.error('Error deleting department:', error);
                throw error;
            } finally {
                this.isLoading = false;
            }
        },

        async checkUserDepartment(clubId) {
            this.loading = true;
            try {
                const data = await DepartmentService.checkUserDepartment(clubId);
                this.userRole = data;
                console.log('User role:', this.userRole); // Log the user role
                this.error = null;
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error checking user department:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        }
    }
});